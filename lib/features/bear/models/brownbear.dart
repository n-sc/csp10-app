class BrownBear {
  final bool available;
  final DateTime created;
  final int id;
  final DateTime lastUpdated;
  final String ownerID;
  final Object owner;
  final String? targetID;
  final Object? target;

  BrownBear({
    required this.available,
    required this.created,
    required this.id,
    required this.lastUpdated,
    required this.ownerID,
    required this.owner,
    this.targetID,
    this.target,
  });

  factory BrownBear.fromJson(Map<String, dynamic> data) {
    if (data
        case {
          'available': bool available,
          'created': String created,
          'id': int id,
          'last_updated': String lastUpdated,
          'owner_id': String ownerID,
          'owner': Object owner,
        }) {
      final targetID = data['target_id'] as String?;
      final target = data['target'] as Object?;
      return BrownBear(
        available: available,
        created: DateTime.parse(created),
        id: id,
        lastUpdated: DateTime.parse(lastUpdated),
        ownerID: ownerID,
        owner: owner,
        targetID: targetID,
        target: target,
      );
    } else {
      throw const FormatException('Could not validate BrownBear data!');
    }
  }
}
