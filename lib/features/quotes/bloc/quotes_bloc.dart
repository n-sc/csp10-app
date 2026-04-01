import 'dart:developer' show log;

import 'package:csp10_app/core/models/user.dart';
import 'package:csp10_app/core/repositories/user_repository.dart';
import 'package:csp10_app/features/quotes/models/quote.dart';
import 'package:csp10_app/features/quotes/quotes_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'quotes_event.dart';
part 'quotes_state.dart';

class QuotesBloc extends Bloc<QuotesEvent, QuotesState> {
  QuotesBloc({
    required QuotesRepository quotesRepository,
    required UserRepository userRepository,
  })  : _quotesRepository = quotesRepository,
        _userRepository = userRepository,
        super(QuotesInitial()) {
    on<QuotesOverviewRequest>(_onQuotesOverviewRequest);
    on<QuotesOverviewRefresh>(_onQuotesOverviewRefresh);
    on<QuotesAuthorsRequest>(_onQuotesAuthorsRequest);
    on<QuotesQuoteCreate>(_onQuotesQuoteCreate);
    on<QuotesQuoteDelete>(_onQuotesQuoteDelete);
  }

  final QuotesRepository _quotesRepository;
  final UserRepository _userRepository;

  @override
  void onTransition(Transition<QuotesEvent, QuotesState> transition) {
    super.onTransition(transition);
    log('QuotesBloc transition: ${transition.currentState} -> ${transition.nextState}');
  }

  @override
  void onError(Object error, StackTrace stackTrace) {
    super.onError(error, stackTrace);
    log('QuotesBloc error: $error');
  }

  void _onQuotesOverviewRequest(
    QuotesOverviewRequest event,
    Emitter<QuotesState> emit,
  ) async {
    emit(const QuotesLoading());
    try {
      var quotes = await _quotesRepository.quotes;
      emit(QuotesLoaded(quotes));
    } catch (e) {
      emit(QuotesError(e.toString()));
    }
  }

  void _onQuotesOverviewRefresh(
    QuotesOverviewRefresh event,
    Emitter<QuotesState> emit,
  ) async {
    emit(const QuotesLoading());
    try {
      final quotes = await _quotesRepository.refreshQuotes();
      emit(QuotesLoaded(quotes));
    } catch (e) {
      emit(QuotesError(e.toString()));
    }
  }

  void _onQuotesAuthorsRequest(
    QuotesAuthorsRequest event,
    Emitter<QuotesState> emit,
  ) async {
    try {
      final users = await _userRepository.users;
      emit(QuotesAuthorsLoaded(users));
    } catch (e) {
      emit(QuotesAuthorsError(e.toString()));
    }
  }

  void _onQuotesQuoteCreate(
    QuotesQuoteCreate event,
    Emitter<QuotesState> emit,
  ) async {
    try {
      final quote = await _quotesRepository.createQuote(event.data);
      emit(QuotesCreationSuccess(quote));

      // wait a second before reloading the quotes
      await Future<void>.delayed(Duration(seconds: 1));
      add(const QuotesOverviewRefresh());
    } catch (e) {
      emit(QuotesCreationError(e.toString()));
    }
  }

  void _onQuotesQuoteDelete(
    QuotesQuoteDelete event,
    Emitter<QuotesState> emit,
  ) async {
    try {
      await _quotesRepository.deleteQuote(event.id);
      emit(const QuotesDeletionSuccess());
      add(const QuotesOverviewRefresh());
    } catch (e) {
      emit(QuotesDeletionError(e.toString()));
    }
  }
}
