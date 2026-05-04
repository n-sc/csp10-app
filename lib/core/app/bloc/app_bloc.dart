import 'dart:async' show StreamSubscription;
import 'dart:developer';

import 'package:csp10_app/core/repositories/authentication_repository.dart';
import 'package:csp10_app/core/models/user.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

part 'app_event.dart';
part 'app_state.dart';

class AppBloc extends Bloc<AppEvent, AppState> {
  AppBloc({required AuthenticationRepository authenticationRepository})
      : _authenticationRepository = authenticationRepository,
        super(AppState(user: authenticationRepository.currentUser)) {
    on<_AppUserChanged>(_onAppUserChanged);
    on<AppLoginRequested>(_onAppLoginRequested);
    on<AppLogoutPressed>(_onLogoutPressed);
    on<AppSwitchTheme>(_onAppSwitchTheme);
    // Subscribe to user stream so any internal change (login, restore,
    // logout, refresh) automatically propagates to bloc state.
    _userSubscription = _authenticationRepository.user.listen(
      (user) => add(_AppUserChanged(user: user)),
      onError: addError,
    );
  }

  final AuthenticationRepository _authenticationRepository;
  late final StreamSubscription<User> _userSubscription;

  @override
  Future<void> close() {
    _userSubscription.cancel();
    return super.close();
  }

  @override
  void onTransition(Transition<AppEvent, AppState> transition) {
    super.onTransition(transition);
    log('AppBloc transition: ${transition.currentState} -> ${transition.nextState}');
  }

  @override
  void onError(Object error, StackTrace stackTrace) {
    super.onError(error, stackTrace);
    log('AppBloc error: $error');
  }

  void _onAppUserChanged(
    _AppUserChanged event,
    Emitter<AppState> emit,
  ) {
    emit(state.copyWith(user: event.user));
  }

  Future<void> _onAppLoginRequested(
    AppLoginRequested event,
    Emitter<AppState> emit,
  ) async {
    try {
      await _authenticationRepository.logIn(event.json);
      // State update is handled by the _userSubscription → _AppUserChanged.
    } catch (e) {
      addError(e);
    }
  }

  void _onLogoutPressed(
    AppLogoutPressed event,
    Emitter<AppState> emit,
  ) {
    _authenticationRepository.logOut();
    // State update is handled by the _userSubscription → _AppUserChanged.
  }

  void _onAppSwitchTheme(
    AppSwitchTheme event,
    Emitter<AppState> emit,
  ) {
    emit(state.copyWith(themeMode: event.mode));
  }
}
