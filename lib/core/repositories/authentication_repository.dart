import 'dart:async';
import 'dart:convert' show jsonDecode;
import 'dart:developer' show log;
import 'dart:io' show HttpException;

import 'package:csp10_app/core/models/user.dart';
import 'package:csp10_app/core/services/api/api.dart';
import 'package:csp10_app/core/services/api/models/responses.dart';
import 'package:csp10_app/core/services/service_locator.dart';

class Session {
  final Map<String, dynamic>? authData;

  const Session({
    this.authData,
  });

  static const empty = Session(authData: {});
}

class AuthenticationRepository {
  final _userController = StreamController<User>();
  User _user = User.empty;
  Session _session = Session.empty;

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

    _session = Session(authData: authData);

    // TODO decouple this API call
    // maybe return access token and set it on a higher level?
    locator.get<API>().accessToken = authData['access_token'] as String;

    var user = await _fetchUserData();
    log('Login as user $user');
    _user = user;
    _userController.add(_user);
  }

  void logOut() {
    _user = User.empty;
    _userController.add(_user);
  }

  void dispose() => _userController.close();

  Future<User> _fetchUserData() async {
    var response = await locator.get<API>().getProtected('/users/current');
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
}

class MockAuthenticationRepository extends AuthenticationRepository {
  @override
  // ignore: overridden_fields
  User _user = User(name: 'M', surname: 'Ock', username: 'mock');
}
