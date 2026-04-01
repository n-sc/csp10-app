class UserObject {
  final String id;
  final String username;

  UserObject({
    required this.id,
    required this.username,
  });

  factory UserObject.fromMap(Map<String, dynamic> m) {
    if (m
        case {
          'id': String id,
          'username': String username,
        }) {
      return UserObject(
        id: id,
        username: username,
      );
    } else {
      throw const FormatException('Could not validate UserObject data!');
    }
  }
}

class BearTypeObject {
  final int id;
  final String displayName;

  BearTypeObject({
    required this.id,
    required this.displayName,
  });

  factory BearTypeObject.fromMap(Map<String, dynamic> m) {
    if (m
        case {
          'id': int id,
          'display_name': String displayName,
        }) {
      return BearTypeObject(
        id: id,
        displayName: displayName,
      );
    } else {
      throw const FormatException('Could not validate BearTypeObject data!');
    }
  }
}

class BearObject {
  final int id;
  final BearTypeObject type;

  BearObject({
    required this.id,
    required this.type,
  });

  factory BearObject.fromMap(Map<String, dynamic> m) {
    if (m
        case {
          'id': int id,
          'type': Map<String, dynamic> type,
        }) {
      return BearObject(id: id, type: BearTypeObject.fromMap(type));
    } else {
      throw const FormatException('Could not validate BearObject data!');
    }
  }
}

class BearTransaction {
  final int id;
  final String? beverage;
  final int? amount;
  final bool? receiverConfirmed;
  final bool? senderConfirmed;
  final DateTime startTimestamp;
  final DateTime? endTimestamp;
  final int? duration;
  final String senderID;
  final String sender;
  final String receiverID;
  final String receiver;
  final bool receiverProtected;
  final int bearID;
  final String bear;
  final int remaining;

  BearTransaction({
    required this.id,
    this.beverage,
    this.amount,
    this.receiverConfirmed,
    this.senderConfirmed,
    required this.startTimestamp,
    this.endTimestamp,
    this.duration,
    required this.senderID,
    required this.sender,
    required this.receiverID,
    required this.receiver,
    required this.receiverProtected,
    required this.bearID,
    required this.bear,
    required this.remaining,
  });

  factory BearTransaction.fromJson(Map<String, dynamic> data) {
    if (data
        case {
          'id': int id,
          'start_timestamp': String startTimestamp,
          'sender_id': String senderID,
          'sender': String sender,
          'receiver_id': String receiverID,
          'receiver': String receiver,
          'receiver_protected': bool receiverProtected,
          'bear_id': int bearID,
          'bear': String bear,
          'remaining': int remaining,
        }) {
      final beverage = data['beverage'] as String?;
      final amount = data['amount'] as int?;
      final receiverConfirmed = data['receiver_confirmed'] as bool?;
      final senderConfirmed = data['sender_confirmed'] as bool?;
      final startTime = DateTime.parse(startTimestamp);
      final endTimestamp = data['end_timestamp'] != null
          ? DateTime.parse(data['end_timestamp'] as String)
          : null;
      final duration = data['duration'] as int?;

      return BearTransaction(
        id: id,
        beverage: beverage,
        amount: amount,
        receiverConfirmed: receiverConfirmed,
        senderConfirmed: senderConfirmed,
        startTimestamp: startTime,
        endTimestamp: endTimestamp,
        duration: duration,
        senderID: senderID,
        sender: sender,
        receiverID: receiverID,
        receiver: receiver,
        receiverProtected: receiverProtected,
        bearID: bearID,
        bear: bear,
        remaining: remaining,
      );
    } else {
      throw const FormatException('Could not validate BearTransaction data!');
    }
  }
}
