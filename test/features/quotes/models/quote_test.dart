import 'package:csp10_app/features/quotes/models/quote.dart';
import 'package:flutter_test/flutter_test.dart';

Map<String, dynamic> _validPayload({
  int id = 1,
  String quoteText = 'Hello world',
}) =>
    {
      'id': id,
      'quote': quoteText,
      'author': {'username': 'alice'},
      'submitter': {'username': 'bob'},
      'city': 'Berlin',
      'context': 'At the office',
      'location': 'Room 42',
      'date': '2026-04-09T10:00:00',
    };

void main() {
  group('Quote.fromJson', () {
    test('parses full payload correctly', () {
      final quote = Quote.fromJson(_validPayload());

      expect(quote.id, 1);
      expect(quote.quote, 'Hello world');
      expect(quote.author, 'alice');
      expect(quote.submitter, 'bob');
      expect(quote.city, 'Berlin');
      expect(quote.context, 'At the office');
      expect(quote.location, 'Room 42');
      expect(quote.date, DateTime.parse('2026-04-09T10:00:00'));
    });

    test('throws FormatException when id is missing', () {
      final payload = _validPayload()..remove('id');
      expect(
        () => Quote.fromJson(payload),
        throwsA(isA<FormatException>()),
      );
    });

    test('throws FormatException when author object is missing', () {
      final payload = _validPayload()..remove('author');
      expect(
        () => Quote.fromJson(payload),
        throwsA(isA<FormatException>()),
      );
    });

    test('throws FormatException when date is missing', () {
      final payload = _validPayload()..remove('date');
      expect(
        () => Quote.fromJson(payload),
        throwsA(isA<FormatException>()),
      );
    });

    test('throws on invalid date string', () {
      final payload = _validPayload();
      payload['date'] = 'not-a-date';
      expect(
        () => Quote.fromJson(payload),
        throwsA(isA<FormatException>()),
      );
    });
  });
}
