import 'dart:convert' show jsonDecode;
import 'dart:developer' show log;

import 'package:csp10_app/core/app/bloc/app_bloc.dart';
import 'package:csp10_app/core/data/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:webview_flutter/webview_flutter.dart';

class LoginScreenWebview extends StatefulWidget {
  const LoginScreenWebview({super.key});

  @override
  State<LoginScreenWebview> createState() => _LoginScreenWebviewState();
}

class _LoginScreenWebviewState extends State<LoginScreenWebview> {
  static const String _loginUri = '${Constants.apiURL}/oauth';
  static const String _keycloakUri = Constants.keycloakURL;
  static const String _callbackUri = '${Constants.apiURL}/oauth/callback';
  late final WebViewController _webController;
  bool _isLoginReady = false;
  bool _isLoggingIn = false;
  bool _showError = false;
  Object _errorMessage = '';
  int _pageProgress = 0;

  @override
  void initState() {
    super.initState();
    // TODO try logging in the user with data from disk before creating a webview
    _webController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Update loading bar.
            _pageProgress = progress;
          },
          onPageStarted: (String url) {
            log('webview: started loading $url!');
          },
          onPageFinished: (String url) {
            log('webview: finished loading $url! (p=$_pageProgress)');
            if (_pageProgress == 100) {
              if (url.startsWith(_callbackUri)) {
                setState(() {
                  _isLoggingIn = true;
                });
                _extractToken(url);
              } else if (url.startsWith(_keycloakUri)) {
                setState(() {
                  _isLoginReady = true;
                });
              }
            }
          },
          onHttpError: (HttpResponseError error) {},
          onWebResourceError: (WebResourceError error) {},
          onNavigationRequest: (NavigationRequest request) {
            return NavigationDecision.navigate;
          },
          onUrlChange: (UrlChange change) async {},
        ),
      )
      ..loadRequest(Uri.parse(_loginUri));
  }

  void _extractToken(String uri) async {
    // TODO check if request was successful
    final String t = await _webController
        .runJavaScriptReturningResult('document.body.textContent') as String;
    // The string from JS is double encoded (only on Android), remove first layer here
    String token;
    try {
      token = jsonDecode(t) as String;
    } catch (e) {
      token = t;
    }
    log("Token: $token");
    try {
      if (mounted) {
        context.read<AppBloc>().add(AppLoginRequested(json: token));
      }
    } catch (e) {
      setState(() {
        _showError = true;
        _errorMessage = e;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_showError) {
      return ErrorWidget(_errorMessage);
    }
    if (_isLoginReady && !_isLoggingIn) {
      return WebViewWidget(
        controller: _webController,
      );
    } else {
      return Scaffold(
        body: const Center(
          child: CircularProgressIndicator.adaptive(),
        ),
      );
    }
  }
}
