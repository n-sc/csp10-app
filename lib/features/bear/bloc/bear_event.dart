part of 'bear_bloc.dart';

sealed class BearEvent extends Equatable {
  const BearEvent();

  @override
  List<Object> get props => [];
}

final class BearOverviewRequest extends BearEvent {
  const BearOverviewRequest();
}

final class BrownBearAttackTargetsRequest extends BearEvent {
  const BrownBearAttackTargetsRequest();
}

final class BrownBearAttack extends BearEvent {
  final String target;
  const BrownBearAttack({required this.target});
}

final class BearTransactionsRequest extends BearEvent {
  const BearTransactionsRequest();
}

final class BearTransactionsRefresh extends BearEvent {
  const BearTransactionsRefresh();
}

final class BearTransactionConfirmation extends BearEvent {
  final Completer<bool> completer;
  final int transactionId;

  const BearTransactionConfirmation({
    required this.completer,
    required this.transactionId,
  });
}
