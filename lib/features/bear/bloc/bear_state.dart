part of 'bear_bloc.dart';

// Basic states

sealed class BearState {
  const BearState();
}

final class BearInitial extends BearState {
  const BearInitial();
}

final class BearLoading extends BearState {
  const BearLoading();
}

sealed class BearError extends BearState {
  final String error;

  const BearError(this.error);
}

// BearOverview

sealed class BearOverviewState extends BearState {
  const BearOverviewState();
}

final class BearOverviewLoading extends BearOverviewState {
  const BearOverviewLoading();
}

final class BearOverviewLoaded extends BearOverviewState {
  final List<BearType> types;
  final Map<String, int> countsByTypeName;

  const BearOverviewLoaded(this.types, this.countsByTypeName);
}

final class BearOverviewError extends BearOverviewState implements BearError {
  @override
  final String error;

  const BearOverviewError(this.error);
}

// BearTransactions

sealed class BearTransactionsState extends BearState {
  const BearTransactionsState();
}

final class BearTransactionsLoading extends BearTransactionsState {
  const BearTransactionsLoading();
}

final class BearTransactionsLoaded extends BearTransactionsState {
  final List<BearTransaction> transactions;
  final List<BearTransaction> ownTransactions;

  const BearTransactionsLoaded(this.transactions, this.ownTransactions);
}

final class BearTransactionsError extends BearTransactionsState
    implements BearError {
  @override
  final String error;

  const BearTransactionsError(this.error);
}

// BrownBearAttack

sealed class BrownBearAttackState extends BearState {
  const BrownBearAttackState();
}

final class BrownBearAttackTargetsLoaded extends BrownBearAttackState {
  final List<User> targets;

  const BrownBearAttackTargetsLoaded(this.targets);
}

final class BrownBearAttackTargetsError extends BrownBearAttackState
    implements BearError {
  @override
  final String error;

  const BrownBearAttackTargetsError(this.error);
}

final class BrownBearAttackLoading extends BrownBearAttackState {
  const BrownBearAttackLoading();
}

final class BrownBearAttackSuccess extends BrownBearAttackState {
  const BrownBearAttackSuccess();
}

final class BrownBearAttackCooldown extends BrownBearAttackState {
  const BrownBearAttackCooldown();
}

final class BrownBearAttackActiveTransaction extends BrownBearAttackState {
  const BrownBearAttackActiveTransaction();
}

final class BrownBearAttackFailure extends BrownBearAttackState
    implements BearError {
  @override
  final String error;

  const BrownBearAttackFailure(this.error);
}
