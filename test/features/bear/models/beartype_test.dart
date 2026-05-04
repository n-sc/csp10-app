import 'package:csp10_app/features/bear/models/beartype.dart';
import 'package:flutter_test/flutter_test.dart';

Map<String, dynamic> _validPayload() => {
      'id': 1,
      'name': 'brown_bear',
      'display_name': 'Brown Bear',
      'description': 'The classic bear.',
      'received_by': 'opponent',
      'scope': 'global',
      'single_use': true,
      'type': 'offensive',
    };

void main() {
  group('BearType.fromJson', () {
    test('parses full payload correctly', () {
      final bearType = BearType.fromJson(_validPayload());

      expect(bearType.id, 1);
      expect(bearType.name, 'brown_bear');
      expect(bearType.displayName, 'Brown Bear');
      expect(bearType.description, 'The classic bear.');
      expect(bearType.receivedBy, 'opponent');
      expect(bearType.scope, 'global');
      expect(bearType.singleUse, isTrue);
      expect(bearType.type, 'offensive');
    });

    test('throws FormatException when id is missing', () {
      final payload = _validPayload()..remove('id');
      expect(
        () => BearType.fromJson(payload),
        throwsA(isA<FormatException>()),
      );
    });

    test('throws FormatException when single_use is wrong type', () {
      final payload = _validPayload();
      payload['single_use'] = 'yes'; // should be bool
      expect(
        () => BearType.fromJson(payload),
        throwsA(isA<FormatException>()),
      );
    });

    test('throws FormatException when display_name is missing', () {
      final payload = _validPayload()..remove('display_name');
      expect(
        () => BearType.fromJson(payload),
        throwsA(isA<FormatException>()),
      );
    });
  });
}
