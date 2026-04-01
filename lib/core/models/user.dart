class User {
  final String? name;
  final String? surname;
  final String username;

  const User({
    required this.name,
    required this.surname,
    required this.username,
  });

  static const empty = User(name: '-', surname: '-', username: '-');

  factory User.fromJson(Map<String, dynamic> data) {
    if (data
        case {
          'name': String? name,
          'surname': String? surname,
          'username': String username,
        }) {
      return User(
        name: name,
        surname: surname,
        username: username,
      );
    } else {
      throw const FormatException('Could not validate User data!');
    }
  }

  @override
  String toString() {
    return '$username ($name $surname)';
  }
}
