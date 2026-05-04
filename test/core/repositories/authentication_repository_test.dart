import 'dart:convert';

import 'package:csp10_app/core/models/user.dart';
import 'package:csp10_app/core/repositories/authentication_repository.dart';
import 'package:csp10_app/core/services/api/api.dart';
import 'package:csp10_app/core/services/api/models/responses.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeApi extends API {
  APIResponse getProtectedResponse = ContentAPIResponse({
    'username': 'user',
    'name': 'Name',
    'surname': 'Surname',
  });
  APIResponse postResponse =
      ErrorAPIResponse('Post response not configured in test.');

  int setSessionTokenCount = 0;
  bool didClearSession = false;
  String? lastPostPath;
  Map<String, Object>? lastPostBody;

  @override
  Future<APIResponse> getProtected(String path) async {
    return getProtectedResponse;
  }

  @override
  Future<APIResponse> post(String path, Map<String, Object> body) async {
    lastPostPath = path;
    lastPostBody = body;
    return postResponse;
  }

  @override
  void setSessionToken({
    required String accessToken,
    required int expiresInSeconds,
  }) {
    setSessionTokenCount += 1;
  }

  @override
  void clearSession() {
    didClearSession = true;
  }
}

void main() {
  group('AuthenticationRepository', () {
    late FakeApi api;
    late AuthenticationRepository repository;

    setUp(() {
      api = FakeApi();
      repository = AuthenticationRepository(apiClient: api);
    });

    tearDown(() {
      repository.dispose();
    });

    test('logIn validates payload, fetches user and updates state', () async {
      final loginPayload = jsonEncode({
        'access_token': 'access-token-1',
        'expires_in': 60,
        'refresh_expires_in': 600,
        'refresh_token': 'refresh-token-1',
      });
      api.getProtectedResponse = ContentAPIResponse({
        'username': 'alice',
        'name': 'Alice',
        'surname': 'Smith',
      });

      await repository.logIn(loginPayload);

      expect(repository.currentUser.username, 'alice');
      expect(repository.currentSession.authData?['access_token'], 'access-token-1');
      expect(repository.currentSession.accessTokenExpiresAt, isNotNull);
      expect(api.setSessionTokenCount, 1);
    });

    test('refreshSession posts refresh_token and updates token session', () async {
      final loginPayload = jsonEncode({
        'access_token': 'access-token-initial',
        'expires_in': 60,
        'refresh_expires_in': 600,
        'refresh_token': 'refresh-token-initial',
      });

      api.postResponse = ContentAPIResponse({
        'access_token': 'access-token-refreshed',
        'expires_in': 120,
        'refresh_expires_in': 600,
        'refresh_token': 'refresh-token-refreshed',
      });

      await repository.logIn(loginPayload);
      final refreshed = await repository.refreshSession();

      expect(refreshed, isTrue);
      expect(api.lastPostPath, '/oauth/refresh');
      expect(api.lastPostBody, {'refresh_token': 'refresh-token-initial'});
      expect(repository.currentSession.authData?['access_token'], 'access-token-refreshed');
      expect(api.setSessionTokenCount, 2);
    });

    test('refreshSession returns false without active session', () async {
      final refreshed = await repository.refreshSession();

      expect(refreshed, isFalse);
      expect(api.lastPostPath, isNull);
    });

    test('logOut resets user and clears API session', () {
      repository.logOut();

      expect(repository.currentUser, User.empty);
      expect(repository.currentSession.authData, Session.empty.authData);
      expect(api.didClearSession, isTrue);
    });
  });
}
