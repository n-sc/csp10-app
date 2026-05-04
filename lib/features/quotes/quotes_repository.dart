import 'package:csp10_app/core/services/api/api.dart';
import 'package:csp10_app/core/services/api/models/responses.dart';
import 'package:csp10_app/features/quotes/models/quote.dart';

class QuotesRepository {
  final API _apiclient;
  List<Quote>? _quotes;

  QuotesRepository({required API apiClient}) : _apiclient = apiClient;

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
      case ErrorAPIResponse error:
        throw error;
      default:
        throw ErrorAPIResponse('Unexpected response in createQuote()');
    }
  }

  Future<void> deleteQuote(int id) async {
    var response = await _apiclient.deleteProtected('/quotes/$id');
    switch (response) {
      case EmptyAPIResponse _:
        return;
      case ErrorAPIResponse error:
        throw error;
      default:
        throw ErrorAPIResponse('Unexpected response in deleteQuote()');
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
      case ErrorAPIResponse error:
        throw error;
      default:
        throw ErrorAPIResponse('Unexpected response in _getAllQuotes()');
    }
  }
}
