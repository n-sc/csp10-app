import 'dart:async';
import 'dart:convert' show jsonDecode;
import 'dart:developer' show log;
import 'dart:io' show HttpException;

import 'package:csp10_app/core/models/user.dart';
import 'package:csp10_app/core/services/api/api.dart';
import 'package:csp10_app/core/services/api/models/responses.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class Session {
  final Map<String, dynamic>? authData;
  final DateTime? accessTokenExpiresAt;

  const Session({
    this.authData,
    this.accessTokenExpiresAt,
  });

  static const empty = Session(authData: {});
}

class AuthenticationRepository {
  final API _api;
  final FlutterSecureStorage? _storage;
  final _userController = StreamController<User>();
  User _user = User.empty;
  Session _session = Session.empty;

  // Namespaced keys keep app auth data isolated in secure device storage.
  static const _kAccessToken = 'csp10_access_token';
  static const _kRefreshToken = 'csp10_refresh_token';
  static const _kExpiresIn = 'csp10_expires_in';
  static const _kRefreshExpiresIn = 'csp10_refresh_expires_in';

  AuthenticationRepository({required API apiClient, FlutterSecureStorage? storage})
      : _api = apiClient,
        _storage = storage {
    _api.registerRefreshSessionCallback(refreshSession);
  }

  Stream<User> get user async* {
    // await Future<void>.delayed(const Duration(seconds: 1));
    yield _user;
    yield* _userController.stream;
  }

  User get currentUser {
    return _user;
  }

  Session get currentSession {
    return _session;
  }

  Future<void> logIn(String json) async {
    var authData = _validateJSON(json);
    log('$authData');
    _setSession(authData);
    await _persistSession(authData);

    var user = await _fetchUserData();
    log('Login as user $user');
    _user = user;
    _userController.add(_user);
  }

  /// Attempts to restore a previously saved session from secure device storage.
  ///
  /// Returns `true` if stored tokens were found, the refresh succeeded, and
  /// the user profile was fetched. Returns `false` in all other cases and
  /// cleans up any stale stored data.
  Future<bool> tryRestoreSession() async {
    final storage = _storage;
    if (storage == null) return false;

    final refreshToken = await storage.read(key: _kRefreshToken);
    if (refreshToken == null || refreshToken.isEmpty) return false;

    final accessToken = await storage.read(key: _kAccessToken) ?? '';
    final expiresIn =
        int.tryParse(await storage.read(key: _kExpiresIn) ?? '') ?? 0;
    final refreshExpiresIn =
        int.tryParse(await storage.read(key: _kRefreshExpiresIn) ?? '') ?? 0;

    // Restore a temporary in-memory session so refreshSession() can use the
    // persisted refresh token to mint a fresh access token.
    _setSession({
      'access_token': accessToken,
      'expires_in': expiresIn,
      'refresh_expires_in': refreshExpiresIn,
      'refresh_token': refreshToken,
    });

    final refreshed = await refreshSession();
    if (!refreshed) {
      _session = Session.empty;
      _api.clearSession();
      await _clearPersistedSession();
      return false;
    }

    try {
      final user = await _fetchUserData();
      _user = user;
      _userController.add(_user);
      return true;
    } catch (e) {
      log('tryRestoreSession: failed to fetch user data: $e');
      _session = Session.empty;
      _api.clearSession();
      await _clearPersistedSession();
      return false;
    }
  }

  Future<bool> refreshSession() async {
    final authData = _session.authData;
    if (authData == null || authData.isEmpty) {
      return false;
    }

    final refreshToken = authData['refresh_token'];
    if (refreshToken is! String || refreshToken.isEmpty) {
      return false;
    }

    final response = await _api.post('/oauth/refresh', {
      'refresh_token': refreshToken,
    });

    switch (response) {
      case ContentAPIResponse _:
        final data = response.data;
        if (data is! Map<String, dynamic>) {
          return false;
        }
        final payload = _validateJSONMap(data);
        _setSession(payload);
        await _persistSession(payload);
        return true;
      default:
        return false;
    }
  }

  void logOut() {
    _session = Session.empty;
    _user = User.empty;
    _api.clearSession();
    _userController.add(_user);
    unawaited(_clearPersistedSession());
  }

  void dispose() => _userController.close();

  Future<User> _fetchUserData() async {
    var response = await _api.getProtected('/users/current');
    switch (response) {
      case ContentAPIResponse _:
        var user = response.data as Map<String, dynamic>;
        return User.fromJson(user);
      default:
        throw HttpException("Could not get user info");
    }
  }

  /// Matches the given [jsonString] against the expected pattern and returns
  /// the JSON object.
  ///
  /// Throws a [FormatException] if the JSON does not match the pattern.
  Map<String, dynamic> _validateJSON(String jsonString) {
    final jsonObject = jsonDecode(jsonString) as Map<String, dynamic>;
    return _validateJSONMap(jsonObject);
  }

  Map<String, dynamic> _validateJSONMap(Map<String, dynamic> jsonObject) {
    if (jsonObject
        case {
          'access_token': String _,
          'expires_in': int _,
          'refresh_expires_in': int _,
          'refresh_token': String _,
        }) {
      return jsonObject;
    } else {
      throw const FormatException(
          'Could not validate data from login callback!');
    }
  }

  void _setSession(Map<String, dynamic> authData) {
    final expiresAt = DateTime.now().add(
      Duration(seconds: authData['expires_in'] as int),
    );

    _session = Session(
      authData: authData,
      accessTokenExpiresAt: expiresAt,
    );

    _api.setSessionToken(
      accessToken: authData['access_token'] as String,
      expiresInSeconds: authData['expires_in'] as int,
    );
  }

  Future<void> _persistSession(Map<String, dynamic> authData) async {
    final storage = _storage;
    if (storage == null) return;
    // Keep secure storage in sync after both initial login and refresh flows.
    await Future.wait([
      storage.write(
          key: _kAccessToken, value: authData['access_token'] as String),
      storage.write(
          key: _kRefreshToken, value: authData['refresh_token'] as String),
      storage.write(
          key: _kExpiresIn,
          value: (authData['expires_in'] as int).toString()),
      storage.write(
          key: _kRefreshExpiresIn,
          value: (authData['refresh_expires_in'] as int).toString()),
    ]);
  }

  Future<void> _clearPersistedSession() async {
    final storage = _storage;
    if (storage == null) return;
    await Future.wait([
      storage.delete(key: _kAccessToken),
      storage.delete(key: _kRefreshToken),
      storage.delete(key: _kExpiresIn),
      storage.delete(key: _kRefreshExpiresIn),
    ]);
  }
}

class MockAuthenticationRepository extends AuthenticationRepository {
  MockAuthenticationRepository({required super.apiClient}) {
    _user = User(name: 'M', surname: 'Ock', username: 'mock');
  }

  @override
  Stream<User> get user async* {
    yield _user;
  }

  @override
  Future<bool> tryRestoreSession() async => false;
}
