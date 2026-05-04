part of 'app_bloc.dart';

sealed class AppEvent {
  const AppEvent();
}

final class AppLoginRequested extends AppEvent {
  final String json;
  const AppLoginRequested({required this.json});
}

final class AppLogoutPressed extends AppEvent {
  const AppLogoutPressed();
}

final class AppSwitchTheme extends AppEvent {
  final ThemeMode mode;
  const AppSwitchTheme({required this.mode});
}

/// Internal event emitted when the user stream in [AuthenticationRepository]
/// produces a new value. Not intended to be dispatched by external code.
final class _AppUserChanged extends AppEvent {
  final User user;
  const _AppUserChanged({required this.user});
}