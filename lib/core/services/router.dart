import 'dart:async' show StreamSubscription;

import 'package:csp10_app/core/app/bloc/app_bloc.dart';
import 'package:csp10_app/core/repositories/user_repository.dart';
import 'package:csp10_app/core/services/service_locator.dart';
import 'package:csp10_app/core/views/app_shell.dart';
import 'package:csp10_app/core/views/login_webview.dart' show LoginScreenWebview;
import 'package:csp10_app/features/bear/views/bear.dart';
import 'package:csp10_app/features/home/views/home.dart';
import 'package:csp10_app/features/quotes/quotes_branch.dart';
import 'package:csp10_app/features/quotes/quotes_repository.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

GoRouter createRouter({
  required AppBloc appBloc,
}) {
  return GoRouter(
    initialLocation: '/login',
    routes: <RouteBase>[
      StatefulShellRoute.indexedStack(
        builder: (BuildContext context, GoRouterState state,
            StatefulNavigationShell navigationShell) {
          return AppShell(navigationShell: navigationShell);
        },
        branches: <StatefulShellBranch>[
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: '/',
                builder: (context, state) => const HomePage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: '/bears',
                builder: (context, state) => const BearPage(),
              ),
            ],
          ),
          createQuotesBranch(
            quotesRepository: locator.get<QuotesRepository>(),
            userRepository: locator.get<UserRepository>(),
          ),
        ],
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreenWebview(),
      ),
    ],
    redirect: (context, state) {
      final bool loggedIn = appBloc.state.status == AppStatus.authenticated;
      final bool loggingIn = state.matchedLocation == '/login';

      if (!loggedIn) {
        return '/login';
      }

      // if user is logged in but still on /login, send to /
      if (loggingIn) {
        return '/';
      }

      // else: no need to redirect
      return null;
    },
    refreshListenable: GoRouterRefreshStream(appBloc.stream),
  );
}

class GoRouterRefreshStream extends ChangeNotifier {
  late final StreamSubscription<dynamic> _subscription;

  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
          (dynamic _) => notifyListeners(),
        );
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
