import 'package:csp10_app/core/models/user.dart';
import 'package:csp10_app/core/repositories/user_repository.dart';
import 'package:csp10_app/core/services/api/api.dart';
import 'package:csp10_app/features/bear/bear_repository.dart';
import 'package:csp10_app/features/bear/bloc/bear_bloc.dart';
import 'package:csp10_app/features/bear/models/beartransaction.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeBearRepository extends BearRepository {
  FakeBearRepository() : super(apiClient: API());

  int getAllTransactionsCalls = 0;
  int getOwnTransactionsCalls = 0;

  List<BearTransaction> allTransactions = <BearTransaction>[];
  List<BearTransaction> ownTransactions = <BearTransaction>[];

  @override
  Future<List<BearTransaction>> getAllTransactions() async {
    getAllTransactionsCalls += 1;
    return allTransactions;
  }

  @override
  Future<List<BearTransaction>> getOwnTransactions() async {
    getOwnTransactionsCalls += 1;
    return ownTransactions;
  }
}

class FakeUserRepository extends UserRepository {
  FakeUserRepository() : super(apiClient: API());

  @override
  Future<List<User>> get users async {
    return <User>[];
  }

  @override
  Future<List<User>> getUsers() async {
    return <User>[];
  }
}

BearTransaction _transaction(int id) {
  return BearTransaction(
    id: id,
    startTimestamp: DateTime(2026, 1, 1),
    senderID: 'sender-id',
    sender: 'sender',
    receiverID: 'receiver-id',
    receiver: 'receiver',
    receiverProtected: false,
    bearID: 1,
    bear: 'Brown Bear',
    remaining: 120,
  );
}

void main() {
  group('BearBloc transaction loading', () {
    late FakeBearRepository bearRepository;
    late BearBloc bloc;

    setUp(() {
      bearRepository = FakeBearRepository();
      bloc = BearBloc(
        bearRepository: bearRepository,
        userRepository: FakeUserRepository(),
      );
    });

    tearDown(() async {
      await bloc.close();
    });

    test('BearTransactionsRequest emits loading then loaded', () async {
      final transaction = _transaction(10);
      bearRepository.allTransactions = <BearTransaction>[transaction];
      bearRepository.ownTransactions = <BearTransaction>[transaction];

      bloc.add(const BearTransactionsRequest());

      await expectLater(
        bloc.stream,
        emitsInOrder(<dynamic>[
          predicate<BearState>((state) {
            return state.transactionsStatus == BearTransactionsStatus.loading;
          }),
          predicate<BearState>((state) {
            return state.transactionsStatus == BearTransactionsStatus.success &&
                state.transactions.length == 1 &&
                state.ownTransactions.length == 1 &&
                state.transactions.first.id == 10;
          }),
        ]),
      );

      expect(bearRepository.getAllTransactionsCalls, 1);
      expect(bearRepository.getOwnTransactionsCalls, 1);
    });

    test('BearTransactionsRefresh emits loading then loaded', () async {
      final transaction = _transaction(11);
      bearRepository.allTransactions = <BearTransaction>[transaction];
      bearRepository.ownTransactions = <BearTransaction>[transaction];

      bloc.add(const BearTransactionsRefresh());

      await expectLater(
        bloc.stream,
        emitsInOrder(<dynamic>[
          predicate<BearState>((state) {
            return state.transactionsStatus == BearTransactionsStatus.loading;
          }),
          predicate<BearState>((state) {
            return state.transactionsStatus == BearTransactionsStatus.success &&
                state.transactions.length == 1 &&
                state.ownTransactions.length == 1 &&
                state.transactions.first.id == 11;
          }),
        ]),
      );

      expect(bearRepository.getAllTransactionsCalls, 1);
      expect(bearRepository.getOwnTransactionsCalls, 1);
    });
  });
}
