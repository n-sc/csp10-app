import 'package:csp10_app/core/models/user.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('User.fromJson', () {
    test('parses full payload correctly', () {
      final user = User.fromJson({
        'username': 'alice',
        'name': 'Alice',
        'surname': 'Smith',
      });

      expect(user.username, 'alice');
      expect(user.name, 'Alice');
      expect(user.surname, 'Smith');
    });

    test('parses payload with null name and surname', () {
      final user = User.fromJson({
        'username': 'bob',
        'name': null,
        'surname': null,
      });

      expect(user.username, 'bob');
      expect(user.name, isNull);
      expect(user.surname, isNull);
    });

    test('throws FormatException when username is missing', () {
      expect(
        () => User.fromJson({'name': 'Alice', 'surname': 'Smith'}),
        throwsA(isA<FormatException>()),
      );
    });

    test('User.empty has sentinel values', () {
      expect(User.empty.username, '-');
      expect(User.empty.name, '-');
      expect(User.empty.surname, '-');
    });
  });
}
