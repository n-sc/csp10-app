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
        super(const QuotesState()) {
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
    await _loadQuotes(emit);
  }

  void _onQuotesOverviewRefresh(
    QuotesOverviewRefresh event,
    Emitter<QuotesState> emit,
  ) async {
    await _loadQuotes(emit, forceRefresh: true);
  }

  void _onQuotesAuthorsRequest(
    QuotesAuthorsRequest event,
    Emitter<QuotesState> emit,
  ) async {
    emit(state.copyWith(
      authorsStatus: QuotesActionStatus.loading,
      authorsError: null,
    ));
    try {
      final users = await _userRepository.users;
      emit(state.copyWith(
        authorsStatus: QuotesActionStatus.success,
        authors: users,
      ));
    } catch (e) {
      emit(state.copyWith(
        authorsStatus: QuotesActionStatus.failure,
        authorsError: e.toString(),
      ));
    }
  }

  void _onQuotesQuoteCreate(
    QuotesQuoteCreate event,
    Emitter<QuotesState> emit,
  ) async {
    emit(state.copyWith(
      createStatus: QuotesActionStatus.loading,
      createError: null,
      clearCreatedQuote: true,
    ));
    try {
      final quote = await _quotesRepository.createQuote(event.data);
      emit(state.copyWith(
        createStatus: QuotesActionStatus.success,
        createdQuote: quote,
      ));
      add(const QuotesOverviewRefresh());
    } catch (e) {
      emit(state.copyWith(
        createStatus: QuotesActionStatus.failure,
        createError: e.toString(),
      ));
    }
  }

  void _onQuotesQuoteDelete(
    QuotesQuoteDelete event,
    Emitter<QuotesState> emit,
  ) async {
    emit(state.copyWith(
      deleteStatus: QuotesActionStatus.loading,
      deleteError: null,
    ));
    try {
      await _quotesRepository.deleteQuote(event.id);
      emit(state.copyWith(deleteStatus: QuotesActionStatus.success));
      add(const QuotesOverviewRefresh());
    } catch (e) {
      emit(state.copyWith(
        deleteStatus: QuotesActionStatus.failure,
        deleteError: e.toString(),
      ));
    }
  }

  Future<void> _loadQuotes(
    Emitter<QuotesState> emit, {
    bool forceRefresh = false,
  }) async {
    emit(state.copyWith(
      loadStatus: QuotesLoadStatus.loading,
      loadError: null,
      createStatus: QuotesActionStatus.idle,
      deleteStatus: QuotesActionStatus.idle,
      createError: null,
      deleteError: null,
      clearCreatedQuote: true,
    ));
    try {
      final quotes = forceRefresh
          ? await _quotesRepository.refreshQuotes()
          : await _quotesRepository.quotes;
      emit(state.copyWith(
        loadStatus: QuotesLoadStatus.success,
        quotes: quotes,
      ));
    } catch (e) {
      emit(state.copyWith(
        loadStatus: QuotesLoadStatus.failure,
        loadError: e.toString(),
      ));
    }
  }
}
