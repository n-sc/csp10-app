import 'dart:async' show TimeoutException;
import 'dart:convert' show jsonDecode, jsonEncode;
import 'dart:developer' show log;

import 'package:csp10_app/core/data/constants.dart';
import 'package:csp10_app/core/services/api/models/responses.dart';
import 'package:http/http.dart' as http;

typedef RefreshSessionCallback = Future<bool> Function();

class API {
  String? _accessToken;
  DateTime? _accessTokenExpiresAt;
  RefreshSessionCallback? _refreshSessionCallback;
  // Coalesces concurrent refresh attempts when several requests fail at once.
  Future<bool>? _refreshInFlight;

  static const Duration _requestTimeout = Duration(seconds: 30);
  static const Duration _expirySkew = Duration(seconds: 30);

  void setSessionToken({
    required String accessToken,
    required int expiresInSeconds,
  }) {
    _accessToken = accessToken;
    _accessTokenExpiresAt =
        DateTime.now().add(Duration(seconds: expiresInSeconds)).subtract(_expirySkew);
  }

  void clearSession() {
    _accessToken = null;
    _accessTokenExpiresAt = null;
  }

  void registerRefreshSessionCallback(RefreshSessionCallback callback) {
    _refreshSessionCallback = callback;
  }

  bool get hasValidAccessToken {
    if (_accessToken == null || _accessToken!.isEmpty) {
      return false;
    }
    if (_accessTokenExpiresAt == null) {
      return true;
    }
    return DateTime.now().isBefore(_accessTokenExpiresAt!);
  }

  /// Uses the user's session to access protected API resources.
  ///
  /// Returns the decoded data if successful else `null`.
  Future<APIResponse> getProtected(String path) async {
    return _runProtectedRequest(
      method: 'GET',
      path: path,
      runRequest: () => http.get(
        Uri.parse(Constants.apiURL + path),
        headers: _authorizationHeader,
      ),
    );
  }

  Future<APIResponse> postProtected(String path, Map<String, Object> body) async {
    return _runProtectedRequest(
      method: 'POST',
      path: path,
      runRequest: () => http.post(
        Uri.parse(Constants.apiURL + path),
        headers: {
          ..._authorizationHeader,
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      ),
    );
  }

  Future<APIResponse> deleteProtected(String path) async {
    return _runProtectedRequest(
      method: 'DELETE',
      path: path,
      runRequest: () => http.delete(
        Uri.parse(Constants.apiURL + path),
        headers: _authorizationHeader,
      ),
    );
  }

  Future<APIResponse> post(String path, Map<String, Object> body) async {
    try {
      final response = await http
          .post(
            Uri.parse(Constants.apiURL + path),
            headers: {
              'Content-Type': 'application/json',
            },
            body: jsonEncode(body),
          )
          .timeout(_requestTimeout);
      return _responseHandler('POST', path, response);
    } on ErrorAPIResponse {
      rethrow;
    } on TimeoutException {
      return ErrorAPIResponse(
        'POST $path timed out after ${_requestTimeout.inSeconds}s',
        uri: Uri.parse(Constants.apiURL + path),
      );
    } catch (e) {
      return ErrorAPIResponse(e.toString());
    }
  }

  Future<APIResponse> _runProtectedRequest({
    required String method,
    required String path,
    required Future<http.Response> Function() runRequest,
    bool didRetryAfterRefresh = false,
  }) async {
    // Proactively refresh when the local expiry check would fail so we avoid
    // using exception-as-flow-control for the common expired-token case.
    if (!didRetryAfterRefresh && !hasValidAccessToken) {
      final refreshed = await _tryRefreshSession();
      if (refreshed) {
        return _runProtectedRequest(
          method: method,
          path: path,
          runRequest: runRequest,
          didRetryAfterRefresh: true,
        );
      }
    }

    try {
      _assertCanAccessProtectedResource(path);
      final response = await runRequest().timeout(_requestTimeout);

      if (response.statusCode == 401 && !didRetryAfterRefresh) {
        final refreshed = await _tryRefreshSession();
        if (refreshed) {
          return _runProtectedRequest(
            method: method,
            path: path,
            runRequest: runRequest,
            didRetryAfterRefresh: true,
          );
        }
      }

      return _responseHandler(method, path, response);
    } on ErrorAPIResponse catch (error) {
      if (error.statusCode == 401 && !didRetryAfterRefresh) {
        final refreshed = await _tryRefreshSession();
        if (refreshed) {
          return _runProtectedRequest(
            method: method,
            path: path,
            runRequest: runRequest,
            didRetryAfterRefresh: true,
          );
        }
      }
      rethrow;
    } on TimeoutException {
      return ErrorAPIResponse(
        '$method $path timed out after ${_requestTimeout.inSeconds}s',
        uri: Uri.parse(Constants.apiURL + path),
      );
    } catch (e) {
      return ErrorAPIResponse(e.toString());
    }
  }

  Map<String, String> get _authorizationHeader {
    return {'Authorization': 'Bearer $_accessToken'};
  }

  void _assertCanAccessProtectedResource(String path) {
    if (_accessToken == null || _accessToken!.isEmpty) {
      throw ErrorAPIResponse(
        'Missing access token for protected route $path.',
        statusCode: 401,
        uri: Uri.parse(Constants.apiURL + path),
      );
    }

    if (!hasValidAccessToken) {
      throw ErrorAPIResponse(
        'Access token expired for protected route $path. Please log in again.',
        statusCode: 401,
        uri: Uri.parse(Constants.apiURL + path),
      );
    }
  }

  Future<bool> _tryRefreshSession() async {
    if (_refreshSessionCallback == null) {
      return false;
    }

    final pendingRefresh = _refreshInFlight;
    if (pendingRefresh != null) {
      // Reuse the in-flight refresh instead of issuing duplicate refresh calls.
      return pendingRefresh;
    }

    final refreshFuture = Future<bool>.sync(_refreshSessionCallback!).catchError(
      (Object error, StackTrace stackTrace) {
        log('Refresh session callback failed: $error');
        return false;
      },
    );

    _refreshInFlight = refreshFuture;
    return refreshFuture.whenComplete(() {
      _refreshInFlight = null;
    });
  }

  APIResponse _responseHandler(
      String method, String path, http.Response response) {
    log('$method $path finished with status ${response.statusCode}');
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isNotEmpty) {
        final data = jsonDecode(response.body);
        log('$method $path received data: $data');
        if (data is List<dynamic>) {
          return ContentListAPIResponse(data);
        }
        return ContentAPIResponse(data);
      }
      return EmptyAPIResponse();
    }
    throw ErrorAPIResponse(
      '$method $path failed: ${response.body}',
      statusCode: response.statusCode,
      uri: Uri.parse(Constants.apiURL + path),
    );
  }
}
