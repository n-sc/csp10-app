import 'package:csp10_app/core/services/api/api.dart';
import 'package:csp10_app/core/services/api/models/responses.dart';
import 'package:csp10_app/features/quotes/models/quote.dart';

class QuotesRepository {
  final API _apiclient;
  List<Quote>? _quotes;

  QuotesRepository({API? apiClient}) : _apiclient = apiClient ?? API();

  Future<List<Quote>> get quotes async {
    return _quotes ??= await _getAllQuotes();
  }

  Future<List<Quote>> refreshQuotes() async {
    return _quotes = await _getAllQuotes();
  }

  Future<Quote> createQuote(Map<String, String> data) async {
    var response = await _apiclient.postProtected('/quotes', data);
    switch (response) {
      case ContentAPIResponse _:
        return Quote.fromJson(response.data as Map<String, dynamic>);
      default:
        throw ErrorAPIResponse('Error in createQuote()');
    }
  }

  Future<void> deleteQuote(int id) async {
    var response = await _apiclient.deleteProtected('/quotes/$id');
    switch (response) {
      case EmptyAPIResponse _:
        return;
      default:
        throw ErrorAPIResponse('Error in deleteQuote()');
    }
  }

  //
  // INTERNAL FUNCTIONS
  //

  Future<List<Quote>> _getAllQuotes() async {
    var response = await _apiclient.getProtected('/quotes');
    switch (response) {
      case ContentListAPIResponse _:
        List<Quote> quotes = [];
        for (var element in response.data) {
          quotes.add(Quote.fromJson(element as Map<String, dynamic>));
        }
        quotes.sort((a, b) => b.id.compareTo(a.id));
        return quotes;
      default:
        throw ErrorAPIResponse('Error in _getAllQuotes');
    }
  }
}
