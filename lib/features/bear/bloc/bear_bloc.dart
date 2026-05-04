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
      super(const BearState()) {
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
    emit(state.copyWith(
      overviewStatus: BearOverviewStatus.loading,
      overviewError: null,
    ));
    try {
      final types = await _bearRepository.beartypes;
      final Map<String, int> counts = {};

      for (var type in types) {
        counts[type.name] = await _bearRepository.getBearCountByType(type.id);
      }
      emit(state.copyWith(
        overviewStatus: BearOverviewStatus.success,
        types: types,
        countsByTypeName: counts,
      ));
    } catch (e) {
      emit(state.copyWith(
        overviewStatus: BearOverviewStatus.failure,
        overviewError: e.toString(),
      ));
    }
  }

  void _onBrownBearTargetsRequest(
    BrownBearAttackTargetsRequest event,
    Emitter<BearState> emit,
  ) async {
    emit(state.copyWith(
      targetsStatus: BearTargetsStatus.loading,
      targetsError: null,
    ));
    try {
      final targets = await _userRepository.getUsers();
      emit(state.copyWith(
        targetsStatus: BearTargetsStatus.success,
        targets: targets,
      ));
    } catch (e) {
      emit(state.copyWith(
        targetsStatus: BearTargetsStatus.failure,
        targetsError: e.toString(),
      ));
    }
  }

  void _onBrownBearAttack(
    BrownBearAttack event,
    Emitter<BearState> emit,
  ) async {
    emit(state.copyWith(
      attackStatus: BearAttackStatus.loading,
      attackError: null,
    ));
    try {
      final brownBears = await _bearRepository.getBrownBears();
      final payload = {
        'bear_id': brownBears[0].id,
        'target_username': event.target,
      };
      await _bearRepository.useBrownBear(payload);

      emit(state.copyWith(attackStatus: BearAttackStatus.success));
      await _loadTransactions(emit);
    } on ErrorAPIResponse catch (e) {
      if (e.statusCode == 400) {
        if (e.msg.contains('cooldown')) {
          emit(state.copyWith(attackStatus: BearAttackStatus.cooldown));
        } else if (e.msg.contains('active transaction')) {
          emit(state.copyWith(
            attackStatus: BearAttackStatus.activeTransaction,
          ));
        }
      } else {
        emit(state.copyWith(
          attackStatus: BearAttackStatus.failure,
          attackError: e.toString(),
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        attackStatus: BearAttackStatus.failure,
        attackError: e.toString(),
      ));
    }
  }

  void _onBearTransactionsRequest(
    BearTransactionsRequest event,
    Emitter<BearState> emit,
  ) async {
    await _loadTransactions(emit);
  }

  void _onBearTransactionsRefresh(
    BearTransactionsRefresh event,
    Emitter<BearState> emit,
  ) async {
    await _loadTransactions(emit);
  }

  Future<void> _loadTransactions(Emitter<BearState> emit) async {
    emit(state.copyWith(
      transactionsStatus: BearTransactionsStatus.loading,
      transactionsError: null,
      confirmStatus: BearConfirmStatus.idle,
      confirmError: null,
    ));
    try {
      final transactions = await _bearRepository.getAllTransactions();
      final ownTransactions = await _bearRepository.getOwnTransactions();
      emit(state.copyWith(
        transactionsStatus: BearTransactionsStatus.success,
        transactions: transactions,
        ownTransactions: ownTransactions,
      ));
    } catch (e) {
      emit(state.copyWith(
        transactionsStatus: BearTransactionsStatus.failure,
        transactionsError: e.toString(),
      ));
    }
  }

  void _onBearTransactionConfirmation(
    BearTransactionConfirmation event,
    Emitter<BearState> emit,
  ) async {
    emit(state.copyWith(
      confirmStatus: BearConfirmStatus.loading,
      confirmError: null,
    ));
    try {
      final success =
          await _bearRepository.confirmTransaction(event.transactionId);

      await _loadTransactions(emit);
      emit(state.copyWith(confirmStatus: BearConfirmStatus.success));
      event.completer.complete(success);
    } catch (e) {
      emit(state.copyWith(
        confirmStatus: BearConfirmStatus.failure,
        confirmError: e.toString(),
      ));
      if (!event.completer.isCompleted) {
        event.completer.complete(false);
      }
    }
  }
}
