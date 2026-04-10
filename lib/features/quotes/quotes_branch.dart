import 'package:csp10_app/core/repositories/user_repository.dart';
import 'package:csp10_app/features/quotes/bloc/quotes_bloc.dart';
import 'package:csp10_app/features/quotes/quotes_repository.dart';
import 'package:csp10_app/features/quotes/views/quote_add.dart';
import 'package:csp10_app/features/quotes/views/quotes.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

StatefulShellBranch createQuotesBranch({
  required QuotesRepository quotesRepository,
  required UserRepository userRepository,
}) {
  return StatefulShellBranch(
    routes: <RouteBase>[
      ShellRoute(
        builder: (context, state, child) {
          return BlocProvider(
            create: (context) => QuotesBloc(
              quotesRepository: quotesRepository,
              userRepository: userRepository,
            ),
            child: child,
          );
        },
        routes: <RouteBase>[
          GoRoute(
            path: '/quotes',
            builder: (context, state) => const QuotesPage(),
          ),
          GoRoute(
            path: '/quotes/add',
            builder: (context, state) => const QuoteAddScreen(),
          ),
        ],
      ),
    ],
  );
}