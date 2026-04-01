class Quote {
  final String author;
  final String city;
  final String context;
  final DateTime date;
  final int id;
  final String location;
  final String quote;
  final String submitter;

  Quote({
    required this.author,
    required this.city,
    required this.context,
    required this.date,
    required this.id,
    required this.location,
    required this.quote,
    required this.submitter,
  });

  factory Quote.fromJson(Map<String, dynamic> data) {
    if (data
        case {
          'author': Map<String, dynamic> author,
          'city': String city,
          'context': String context,
          'date': String date,
          'id': int id,
          'location': String location,
          'quote': String quote,
          'submitter': Map<String, dynamic> submitter,
        }) {

      return Quote(
        author: author['username']! as String,
        city: city,
        context: context,
        date: DateTime.parse(date),
        id: id,
        location: location,
        quote: quote,
        submitter: submitter['username']! as String,
      );
    } else {
      throw const FormatException('Could not validate Quote data!');
    }
  }
}
