import 'dart:developer' show log;

sealed class APIResponse {}

sealed class SuccessfulAPIResponse extends APIResponse {}

class ErrorAPIResponse extends APIResponse {
  final String msg;
  final int? statusCode;
  final Uri? uri;

  ErrorAPIResponse(this.msg, {this.statusCode, this.uri}) {
    log('API error $statusCode: $msg ($uri)');
  }
}

class EmptyAPIResponse extends SuccessfulAPIResponse {}

class ContentAPIResponse extends SuccessfulAPIResponse {
  final dynamic data;

  ContentAPIResponse(this.data);
}

class ContentListAPIResponse extends SuccessfulAPIResponse {
  final List<dynamic> data;

  ContentListAPIResponse(this.data);
}
