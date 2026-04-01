import 'dart:developer';

import 'package:csp10_app/core/repositories/authentication_repository.dart';
import 'package:csp10_app/core/models/user.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'app_event.dart';
part 'app_state.dart';

class AppBloc extends Bloc<AppEvent, AppState> {
  AppBloc({required AuthenticationRepository authenticationRepository})
      : _authenticationRepository = authenticationRepository,
        super(AppState(user: authenticationRepository.currentUser)) {
    on<AppLoginRequested>(_onAppLoginRequested);
    on<AppLogoutPressed>(_onLogoutPressed);
  }

  final AuthenticationRepository _authenticationRepository;

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

  Future<void> _onAppLoginRequested(
    AppLoginRequested event,
    Emitter<AppState> emit,
  ) async {
    try {
      await _authenticationRepository.logIn(event.json);
      return emit.onEach(
        _authenticationRepository.user,
        onData: (user) => emit(AppState(user: user)),
        onError: addError,
      );
    } catch (e) {
      addError(e);
    }
  }

  void _onLogoutPressed(
    AppLogoutPressed event,
    Emitter<AppState> emit,
  ) {
    _authenticationRepository.logOut();
  }
}
