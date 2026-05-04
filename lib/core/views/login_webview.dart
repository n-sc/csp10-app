import 'dart:convert' show jsonDecode;
import 'dart:developer' show log;

import 'package:csp10_app/core/app/bloc/app_bloc.dart';
import 'package:csp10_app/core/data/constants.dart';
import 'package:csp10_app/core/repositories/authentication_repository.dart';
import 'package:csp10_app/core/widgets/loading_screen.dart';
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
  // Nullable — only initialized after a bootstrap attempt fails.
  WebViewController? _webController;
  bool _isLoginReady = false;
  bool _isLoggingIn = false;
  bool _showError = false;
  Object _errorMessage = '';
  int _pageProgress = 0;

  @override
  void initState() {
    super.initState();
    _tryRestoreSession();
  }

  /// Tries to restore a persisted session. If successful the [AppBloc] state
  /// transitions to authenticated and GoRouter redirects automatically.
  /// If it fails, the interactive WebView is initialized as a fallback.
  Future<void> _tryRestoreSession() async {
    bool restored;
    try {
      restored =
          await context.read<AuthenticationRepository>().tryRestoreSession();
    } catch (e) {
      log('loginWebview: session restore error: $e');
      restored = false;
    }
    if (!mounted || restored) return;
    _initWebView();
    setState(() {});
  }

  void _initWebView() {
    _webController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
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
                _extractToken();
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

  void _extractToken() async {
    final controller = _webController;
    if (controller == null) return;
    final String t = await controller
        .runJavaScriptReturningResult('document.body.textContent') as String;
    // The JS string is double-encoded on Android; decode the outer layer here.
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
    final controller = _webController;
    if (controller != null && _isLoginReady && !_isLoggingIn) {
      return WebViewWidget(controller: controller);
    }
    return const Scaffold(
      body: Center(child: LoadingScreen()),
    );
  }
}
