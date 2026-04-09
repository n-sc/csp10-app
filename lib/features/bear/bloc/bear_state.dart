part of 'bear_bloc.dart';

enum BearOverviewStatus { initial, loading, success, failure }

enum BearTransactionsStatus { initial, loading, success, failure }

enum BearTargetsStatus { initial, loading, success, failure }

enum BearAttackStatus {
  idle,
  loading,
  success,
  cooldown,
  activeTransaction,
  failure,
}

enum BearConfirmStatus { idle, loading, success, failure }

final class BearState extends Equatable {
  const BearState({
    this.overviewStatus = BearOverviewStatus.initial,
    this.transactionsStatus = BearTransactionsStatus.initial,
    this.targetsStatus = BearTargetsStatus.initial,
    this.attackStatus = BearAttackStatus.idle,
    this.confirmStatus = BearConfirmStatus.idle,
    this.types = const <BearType>[],
    this.countsByTypeName = const <String, int>{},
    this.transactions = const <BearTransaction>[],
    this.ownTransactions = const <BearTransaction>[],
    this.targets = const <User>[],
    this.overviewError,
    this.transactionsError,
    this.targetsError,
    this.attackError,
    this.confirmError,
  });

  final BearOverviewStatus overviewStatus;
  final BearTransactionsStatus transactionsStatus;
  final BearTargetsStatus targetsStatus;
  final BearAttackStatus attackStatus;
  final BearConfirmStatus confirmStatus;
  final List<BearType> types;
  final Map<String, int> countsByTypeName;
  final List<BearTransaction> transactions;
  final List<BearTransaction> ownTransactions;
  final List<User> targets;
  final String? overviewError;
  final String? transactionsError;
  final String? targetsError;
  final String? attackError;
  final String? confirmError;

  BearState copyWith({
    BearOverviewStatus? overviewStatus,
    BearTransactionsStatus? transactionsStatus,
    BearTargetsStatus? targetsStatus,
    BearAttackStatus? attackStatus,
    BearConfirmStatus? confirmStatus,
    List<BearType>? types,
    Map<String, int>? countsByTypeName,
    List<BearTransaction>? transactions,
    List<BearTransaction>? ownTransactions,
    List<User>? targets,
    String? overviewError,
    String? transactionsError,
    String? targetsError,
    String? attackError,
    String? confirmError,
  }) {
    return BearState(
      overviewStatus: overviewStatus ?? this.overviewStatus,
      transactionsStatus: transactionsStatus ?? this.transactionsStatus,
      targetsStatus: targetsStatus ?? this.targetsStatus,
      attackStatus: attackStatus ?? this.attackStatus,
      confirmStatus: confirmStatus ?? this.confirmStatus,
      types: types ?? this.types,
      countsByTypeName: countsByTypeName ?? this.countsByTypeName,
      transactions: transactions ?? this.transactions,
      ownTransactions: ownTransactions ?? this.ownTransactions,
      targets: targets ?? this.targets,
      overviewError: overviewError,
      transactionsError: transactionsError,
      targetsError: targetsError,
      attackError: attackError,
      confirmError: confirmError,
    );
  }

  @override
  List<Object?> get props => [
        overviewStatus,
        transactionsStatus,
        targetsStatus,
        attackStatus,
        confirmStatus,
        types,
        countsByTypeName,
        transactions,
        ownTransactions,
        targets,
        overviewError,
        transactionsError,
        targetsError,
        attackError,
        confirmError,
      ];
}
