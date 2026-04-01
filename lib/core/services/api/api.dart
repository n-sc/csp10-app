import 'dart:convert' show jsonDecode, jsonEncode;
import 'dart:developer' show log;

import 'package:csp10_app/core/data/constants.dart';
import 'package:csp10_app/core/services/api/models/responses.dart';
import 'package:http/http.dart' as http;

class API {
  String? _accessToken;

  set accessToken(String token) {
    _accessToken = token;
  }

  /// Uses the user's session to access protected API resources.
  ///
  /// Returns the decoded data if successful else `null`.
  Future<APIResponse> getProtected(String path, {bool isRetry = false}) async {
    // TODO test if accessToken is still valid BEFORE issuing a request
    try {
      final response = await http.get(
        Uri.parse(Constants.apiURL + path),
        headers: {'Authorization': 'Bearer $_accessToken'},
      );
      return _responseHandler('GET', path, response);
    } on ErrorAPIResponse {
      rethrow;
    } catch (e) {
      return ErrorAPIResponse(e.toString());
    }
  }

  Future<APIResponse> postProtected(String path, Map<String, Object> body,
      {bool isRetry = false}) async {
    // TODO test if accessToken is still valid BEFORE issuing a request
    try {
      final response = await http.post(
        Uri.parse(Constants.apiURL + path),
        headers: {
          'Authorization': 'Bearer $_accessToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );
      return _responseHandler('POST', path, response);
    } on ErrorAPIResponse {
      rethrow;
    } catch (e) {
      return ErrorAPIResponse(e.toString());
    }
  }

  Future<APIResponse> deleteProtected(String path,
      {bool isRetry = false}) async {
    // TODO test if accessToken is still valid BEFORE issuing a request
    try {
      final response = await http.delete(
        Uri.parse(Constants.apiURL + path),
        headers: {'Authorization': 'Bearer $_accessToken'},
      );
      return _responseHandler('DELETE', path, response);
    } on ErrorAPIResponse {
      rethrow;
    } catch (e) {
      return ErrorAPIResponse(e.toString());
    }
  }

  APIResponse _responseHandler(
      String method, String path, http.Response response) {
    log('$method $path finished with status ${response.statusCode}');
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isNotEmpty) {
        var data = jsonDecode(response.body);
        log('$method $path received data: $data');
        try {
          // test if the data is a json list
          data = data as List<dynamic>;
          return ContentListAPIResponse(data);
        } catch (e) {
          // discard error
        }
        return ContentAPIResponse(data);
      }
      return EmptyAPIResponse();
    }
    throw ErrorAPIResponse(
      response.body,
      statusCode: response.statusCode,
      uri: Uri(path: path),
    );
  }
}
