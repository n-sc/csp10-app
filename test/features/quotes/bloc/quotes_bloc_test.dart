import 'package:csp10_app/core/models/user.dart';
import 'package:csp10_app/core/repositories/user_repository.dart';
import 'package:csp10_app/core/services/api/api.dart';
import 'package:csp10_app/features/quotes/bloc/quotes_bloc.dart';
import 'package:csp10_app/features/quotes/models/quote.dart';
import 'package:csp10_app/features/quotes/quotes_repository.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeQuotesRepository extends QuotesRepository {
  FakeQuotesRepository() : super(apiClient: API());

  int quotesGetterCalls = 0;
  int refreshCalls = 0;

  List<Quote> quotesData = <Quote>[];
  List<Quote> refreshData = <Quote>[];

  @override
  Future<List<Quote>> get quotes async {
    quotesGetterCalls += 1;
    return quotesData;
  }

  @override
  Future<List<Quote>> refreshQuotes() async {
    refreshCalls += 1;
    return refreshData;
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

Quote _quote(int id, String text) {
  return Quote(
    author: 'author',
    city: 'city',
    context: 'context',
    date: DateTime(2026, 1, 1),
    id: id,
    location: 'location',
    quote: text,
    submitter: 'submitter',
  );
}

void main() {
  group('QuotesBloc overview flows', () {
    late FakeQuotesRepository quotesRepository;
    late QuotesBloc bloc;

    setUp(() {
      quotesRepository = FakeQuotesRepository();
      bloc = QuotesBloc(
        quotesRepository: quotesRepository,
        userRepository: FakeUserRepository(),
      );
    });

    tearDown(() async {
      await bloc.close();
    });

    test('QuotesOverviewRequest emits loading then loaded from cached getter', () async {
      final first = _quote(1, 'cached quote');
      quotesRepository.quotesData = <Quote>[first];

      bloc.add(const QuotesOverviewRequest());

      await expectLater(
        bloc.stream,
        emitsInOrder(<dynamic>[
          predicate<QuotesState>((state) {
            return state.loadStatus == QuotesLoadStatus.loading;
          }),
          predicate<QuotesState>((state) {
            return state.loadStatus == QuotesLoadStatus.success &&
                state.quotes.length == 1 &&
                state.quotes.first.id == 1;
          }),
        ]),
      );

      expect(quotesRepository.quotesGetterCalls, 1);
      expect(quotesRepository.refreshCalls, 0);
    });

    test('QuotesOverviewRefresh emits loading then loaded from refresh API', () async {
      final refreshed = _quote(2, 'fresh quote');
      quotesRepository.refreshData = <Quote>[refreshed];

      bloc.add(const QuotesOverviewRefresh());

      await expectLater(
        bloc.stream,
        emitsInOrder(<dynamic>[
          predicate<QuotesState>((state) {
            return state.loadStatus == QuotesLoadStatus.loading;
          }),
          predicate<QuotesState>((state) {
            return state.loadStatus == QuotesLoadStatus.success &&
                state.quotes.length == 1 &&
                state.quotes.first.id == 2;
          }),
        ]),
      );

      expect(quotesRepository.refreshCalls, 1);
      expect(quotesRepository.quotesGetterCalls, 0);
    });
  });
}
