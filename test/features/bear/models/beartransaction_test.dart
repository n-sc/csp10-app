import 'package:csp10_app/features/bear/models/beartransaction.dart';
import 'package:flutter_test/flutter_test.dart';

Map<String, dynamic> _requiredPayload() => {
      'id': 10,
      'start_timestamp': '2026-04-09T12:00:00',
      'sender_id': 'uid-sender',
      'sender': 'alice',
      'receiver_id': 'uid-receiver',
      'receiver': 'bob',
      'receiver_protected': false,
      'bear_id': 1,
      'bear': 'Brown Bear',
      'remaining': 300,
    };

void main() {
  group('BearTransaction.fromJson', () {
    test('parses required fields correctly', () {
      final tx = BearTransaction.fromJson(_requiredPayload());

      expect(tx.id, 10);
      expect(tx.sender, 'alice');
      expect(tx.receiver, 'bob');
      expect(tx.senderID, 'uid-sender');
      expect(tx.receiverID, 'uid-receiver');
      expect(tx.receiverProtected, isFalse);
      expect(tx.bearID, 1);
      expect(tx.bear, 'Brown Bear');
      expect(tx.remaining, 300);
      expect(tx.startTimestamp, DateTime.parse('2026-04-09T12:00:00'));
    });

    test('parses optional fields when present', () {
      final payload = _requiredPayload();
      payload['beverage'] = 'beer';
      payload['amount'] = 500;
      payload['receiver_confirmed'] = true;
      payload['sender_confirmed'] = false;
      payload['end_timestamp'] = '2026-04-09T12:05:00';
      payload['duration'] = 300;

      final tx = BearTransaction.fromJson(payload);

      expect(tx.beverage, 'beer');
      expect(tx.amount, 500);
      expect(tx.receiverConfirmed, isTrue);
      expect(tx.senderConfirmed, isFalse);
      expect(tx.endTimestamp, DateTime.parse('2026-04-09T12:05:00'));
      expect(tx.duration, 300);
    });

    test('optional fields are null when absent', () {
      final tx = BearTransaction.fromJson(_requiredPayload());

      expect(tx.beverage, isNull);
      expect(tx.amount, isNull);
      expect(tx.receiverConfirmed, isNull);
      expect(tx.senderConfirmed, isNull);
      expect(tx.endTimestamp, isNull);
      expect(tx.duration, isNull);
    });

    test('throws FormatException when id is missing', () {
      final payload = _requiredPayload()..remove('id');
      expect(
        () => BearTransaction.fromJson(payload),
        throwsA(isA<FormatException>()),
      );
    });

    test('throws FormatException when sender is missing', () {
      final payload = _requiredPayload()..remove('sender');
      expect(
        () => BearTransaction.fromJson(payload),
        throwsA(isA<FormatException>()),
      );
    });

    test('throws on invalid start_timestamp', () {
      final payload = _requiredPayload();
      payload['start_timestamp'] = 'not-a-date';
      expect(
        () => BearTransaction.fromJson(payload),
        throwsA(isA<FormatException>()),
      );
    });
  });
}
