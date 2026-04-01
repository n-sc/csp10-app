import 'package:csp10_app/core/app/bloc/app_bloc.dart';
import 'package:csp10_app/core/repositories/authentication_repository.dart';
import 'package:csp10_app/core/repositories/user_repository.dart';
import 'package:csp10_app/core/services/service_locator.dart';
import 'package:csp10_app/features/bear/bear_repository.dart';
import 'package:csp10_app/features/quotes/quotes_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(
          create: (context) => locator.get<AuthenticationRepository>(),
          dispose: (repository) => repository.dispose(),
          lazy: false,
        ),
        RepositoryProvider(
          create: (context) => locator.get<BearRepository>(),
        ),
        RepositoryProvider(
          create: (context) => locator.get<QuotesRepository>(),
        ),
        RepositoryProvider(
          create: (context) => locator.get<UserRepository>(),
        ),
      ],
      child: BlocProvider(
        create: (context) => locator.get<AppBloc>(),
        lazy: false,
        child: AppView(),
      ),
    );
  }
}

class AppView extends StatelessWidget {
  AppView({super.key});

  static const String _title = 'CSP10 App';

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: _title,
      routerConfig: locator.get<GoRouter>(),
    );
  }
}
