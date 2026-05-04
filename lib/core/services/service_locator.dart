import 'package:csp10_app/core/app/bloc/app_bloc.dart';
import 'package:csp10_app/core/repositories/authentication_repository.dart';
import 'package:csp10_app/core/data/constants.dart';
import 'package:csp10_app/core/repositories/user_repository.dart';
import 'package:csp10_app/core/services/api/api.dart';
import 'package:csp10_app/core/services/router.dart';
import 'package:csp10_app/features/bear/bear_repository.dart';
import 'package:csp10_app/features/quotes/quotes_repository.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

final locator = GetIt.instance;

void setupLocator() {
  API api = API();

  AuthenticationRepository authenticationRepository = Constants.useFakeSession
      ? MockAuthenticationRepository(apiClient: api)
      : AuthenticationRepository(
          apiClient: api,
          storage: const FlutterSecureStorage(),
        );
  BearRepository bearRepository = BearRepository(apiClient: api);
  QuotesRepository quotesRepository = QuotesRepository(apiClient: api);
  UserRepository userRepository = UserRepository(apiClient: api);

  AppBloc appBloc = AppBloc(authenticationRepository: authenticationRepository);

  locator.registerSingleton<AuthenticationRepository>(authenticationRepository);
  locator.registerSingleton<BearRepository>(bearRepository);
  locator.registerSingleton<QuotesRepository>(quotesRepository);
  locator.registerSingleton<UserRepository>(userRepository);
  locator.registerSingleton<AppBloc>(appBloc);
  locator.registerSingleton<GoRouter>(createRouter(appBloc: appBloc));
  locator.registerSingleton<API>(api);
}
