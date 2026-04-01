part of 'app_bloc.dart';

enum AppStatus { authenticated, unauthenticated }

final class AppState extends Equatable {
  const AppState({User user = User.empty})
      : this._(
          status: user == User.empty
              ? AppStatus.unauthenticated
              : AppStatus.authenticated,
          user: user,
        );

  AppState copyWith({ThemeMode? themeMode, User? user}) {
    final newUser = user ?? this.user;
    final newStatus = newUser == User.empty ? AppStatus.unauthenticated : AppStatus.authenticated;
    return AppState._(
      status: newStatus,
      themeMode: themeMode ?? this.themeMode,
      user: newUser,
    );
  }

  const AppState._({required this.status, this.themeMode = ThemeMode.system, required this.user});

  final AppStatus status;
  final ThemeMode themeMode;
  final User user;

  @override
  List<Object> get props => [status, themeMode, user];
}
