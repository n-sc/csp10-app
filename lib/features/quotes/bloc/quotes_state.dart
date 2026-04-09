part of 'quotes_bloc.dart';

enum QuotesLoadStatus { initial, loading, success, failure }

enum QuotesActionStatus { idle, loading, success, failure }

final class QuotesState extends Equatable {
  const QuotesState({
    this.loadStatus = QuotesLoadStatus.initial,
    this.authorsStatus = QuotesActionStatus.idle,
    this.createStatus = QuotesActionStatus.idle,
    this.deleteStatus = QuotesActionStatus.idle,
    this.quotes = const <Quote>[],
    this.authors = const <User>[],
    this.loadError,
    this.authorsError,
    this.createError,
    this.deleteError,
    this.createdQuote,
  });

  final QuotesLoadStatus loadStatus;
  final QuotesActionStatus authorsStatus;
  final QuotesActionStatus createStatus;
  final QuotesActionStatus deleteStatus;
  final List<Quote> quotes;
  final List<User> authors;
  final String? loadError;
  final String? authorsError;
  final String? createError;
  final String? deleteError;
  final Quote? createdQuote;

  QuotesState copyWith({
    QuotesLoadStatus? loadStatus,
    QuotesActionStatus? authorsStatus,
    QuotesActionStatus? createStatus,
    QuotesActionStatus? deleteStatus,
    List<Quote>? quotes,
    List<User>? authors,
    String? loadError,
    String? authorsError,
    String? createError,
    String? deleteError,
    Quote? createdQuote,
    bool clearCreatedQuote = false,
  }) {
    return QuotesState(
      loadStatus: loadStatus ?? this.loadStatus,
      authorsStatus: authorsStatus ?? this.authorsStatus,
      createStatus: createStatus ?? this.createStatus,
      deleteStatus: deleteStatus ?? this.deleteStatus,
      quotes: quotes ?? this.quotes,
      authors: authors ?? this.authors,
      loadError: loadError,
      authorsError: authorsError,
      createError: createError,
      deleteError: deleteError,
      createdQuote:
          clearCreatedQuote ? null : (createdQuote ?? this.createdQuote),
    );
  }

  @override
  List<Object?> get props => [
        loadStatus,
        authorsStatus,
        createStatus,
        deleteStatus,
        quotes,
        authors,
        loadError,
        authorsError,
        createError,
        deleteError,
        createdQuote,
      ];
}
