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
