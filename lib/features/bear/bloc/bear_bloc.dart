import 'dart:async' show Completer;
import 'dart:developer' show log;

import 'package:csp10_app/core/models/user.dart';
import 'package:csp10_app/core/repositories/user_repository.dart';
import 'package:csp10_app/core/services/api/models/responses.dart';
import 'package:csp10_app/features/bear/bear_repository.dart';
import 'package:csp10_app/features/bear/models/beartransaction.dart';
import 'package:csp10_app/features/bear/models/beartype.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'bear_event.dart';
part 'bear_state.dart';

class BearBloc extends Bloc<BearEvent, BearState> {
  BearBloc({
    required BearRepository bearRepository,
    required UserRepository userRepository,
  })  : _bearRepository = bearRepository,
        _userRepository = userRepository,
        super(BearInitial()) {
    on<BearOverviewRequest>(_onBearOverviewRequest);
    on<BrownBearAttackTargetsRequest>(_onBrownBearTargetsRequest);
    on<BrownBearAttack>(_onBrownBearAttack);
    on<BearTransactionsRequest>(_onBearTransactionsRequest);
    on<BearTransactionsRefresh>(_onBearTransactionsRefresh);
    on<BearTransactionConfirmation>(_onBearTransactionConfirmation);
  }

  final BearRepository _bearRepository;
  final UserRepository _userRepository;

  @override
  void onTransition(Transition<BearEvent, BearState> transition) {
    super.onTransition(transition);
    log('BearBloc transition: ${transition.currentState} -> ${transition.nextState}');
  }

  @override
  void onError(Object error, StackTrace stackTrace) {
    super.onError(error, stackTrace);
    log('BearBloc error: $error');
  }

  void _onBearOverviewRequest(
    BearOverviewRequest event,
    Emitter<BearState> emit,
  ) async {
    emit(const BearOverviewLoading());
    try {
      final types = await _bearRepository.beartypes;
      final Map<String, int> counts = {};

      for (var type in types) {
        counts[type.name] = await _bearRepository.getBearCountByType(type.id);
      }
      emit(BearOverviewLoaded(types, counts));
    } catch (e) {
      emit(BearOverviewError(e.toString()));
    }
  }

  void _onBrownBearTargetsRequest(
    BrownBearAttackTargetsRequest event,
    Emitter<BearState> emit,
  ) async {
    emit(const BearLoading());
    try {
      final targets = await _userRepository.getUsers();
      emit(BrownBearAttackTargetsLoaded(targets));
    } catch (e) {
      emit(BrownBearAttackTargetsError(e.toString()));
    }
  }

  void _onBrownBearAttack(
    BrownBearAttack event,
    Emitter<BearState> emit,
  ) async {
    emit(const BrownBearAttackLoading());
    try {
      final brownBears = await _bearRepository.getBrownBears();
      final payload = {
        'bear_id': brownBears[0].id,
        'target_username': event.target,
      };
      await _bearRepository.useBrownBear(payload);

      final transactions = await _bearRepository.getAllTransactions();
      final ownTransactions = await _bearRepository.getOwnTransactions();

      emit(BrownBearAttackSuccess());
      emit(BearTransactionsLoaded(transactions, ownTransactions));
    } on ErrorAPIResponse catch (e) {
      if (e.statusCode == 400) {
        if (e.msg.contains('cooldown')) {
          emit(const BrownBearAttackCooldown());
        } else if (e.msg.contains('active transaction')) {
          emit(const BrownBearAttackActiveTransaction());
        }
      } else {
        emit(BrownBearAttackFailure(e.toString()));
      }
    } catch (e) {
      emit(BrownBearAttackFailure(e.toString()));
    }
  }

  void _onBearTransactionsRequest(
    BearTransactionsRequest event,
    Emitter<BearState> emit,
  ) async {
    emit(const BearTransactionsLoading());
    try {
      final transactions = await _bearRepository.getAllTransactions();
      final ownTransactions = await _bearRepository.getOwnTransactions();
      emit(BearTransactionsLoaded(transactions, ownTransactions));
    } catch (e) {
      emit(BearTransactionsError(e.toString()));
    }
  }

  void _onBearTransactionsRefresh(
    BearTransactionsRefresh event,
    Emitter<BearState> emit,
  ) async {
    emit(const BearTransactionsLoading());
    try {
      final transactions = await _bearRepository.getAllTransactions();
      final ownTransactions = await _bearRepository.getOwnTransactions();
      emit(BearTransactionsLoaded(transactions, ownTransactions));
    } catch (e) {
      emit(BearTransactionsError(e.toString()));
    }
  }

  void _onBearTransactionConfirmation(
    BearTransactionConfirmation event,
    Emitter<BearState> emit,
  ) async {
    emit(const BearLoading());
    try {
      final success =
          await _bearRepository.confirmTransaction(event.transactionId);

      final transactions = await _bearRepository.getAllTransactions();
      final ownTransactions = await _bearRepository.getOwnTransactions();

      emit(BearTransactionsLoaded(transactions, ownTransactions));
      event.completer.complete(success);
    } catch (e) {
      emit(BearTransactionsError(e.toString()));
    }
  }
}
