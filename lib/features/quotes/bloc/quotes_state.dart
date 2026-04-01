part of 'quotes_bloc.dart';

sealed class QuotesState extends Equatable {
  const QuotesState();

  @override
  List<Object> get props => [];
}

final class QuotesInitial extends QuotesState {
  const QuotesInitial();
}

final class QuotesLoading extends QuotesState {
  const QuotesLoading();
}

final class QuotesLoaded extends QuotesState {
  final List<Quote> quotes;

  const QuotesLoaded(this.quotes);
}

final class QuotesError extends QuotesState {
  final String error;

  const QuotesError(this.error);
}

final class QuotesAuthorsLoaded extends QuotesState {
  final List<User> users;

  const QuotesAuthorsLoaded(this.users);
}

final class QuotesAuthorsError extends QuotesState implements QuotesError {
  @override
  final String error;

  const QuotesAuthorsError(this.error);
}

final class QuotesCreationSuccess extends QuotesState {
  final Quote quote;

  const QuotesCreationSuccess(this.quote);
}

final class QuotesCreationError extends QuotesState implements QuotesError {
  @override
  final String error;

  const QuotesCreationError(this.error);
}

final class QuotesDeletionSuccess extends QuotesState {
  const QuotesDeletionSuccess();
}

final class QuotesDeletionError extends QuotesState implements QuotesError {
  @override
  final String error;

  const QuotesDeletionError(this.error);
}
