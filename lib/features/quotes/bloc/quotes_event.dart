part of 'quotes_bloc.dart';

sealed class QuotesEvent extends Equatable {
  const QuotesEvent();

  @override
  List<Object> get props => [];
}

final class QuotesOverviewRequest extends QuotesEvent {
  const QuotesOverviewRequest();
}

final class QuotesOverviewRefresh extends QuotesEvent {
  const QuotesOverviewRefresh();
}

final class QuotesAuthorsRequest extends QuotesEvent {
  const QuotesAuthorsRequest();
}

final class QuotesQuoteCreate extends QuotesEvent {
  final Map<String, String> data;

  const QuotesQuoteCreate(this.data);
}

final class QuotesQuoteDelete extends QuotesEvent {
  final int id;

  const QuotesQuoteDelete(this.id);
}
