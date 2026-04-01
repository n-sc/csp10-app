class BearType {
  final String description;
  final String displayName;
  final int id;
  final String name;
  final String receivedBy;
  final String scope;
  final bool singleUse;
  final String type;

  const BearType({
    required this.description,
    required this.displayName,
    required this.id,
    required this.name,
    required this.receivedBy,
    required this.scope,
    required this.singleUse,
    required this.type,
  });

  factory BearType.fromJson(Map<String, dynamic> data) {
    if (data
        case {
          'description': String description,
          'display_name': String displayName,
          'id': int id,
          'name': String name,
          'received_by': String receivedBy,
          'scope': String scope,
          'single_use': bool singleUse,
          'type': String type,
        }) {
      return BearType(
        description: description,
        displayName: displayName,
        id: id,
        name: name,
        receivedBy: receivedBy,
        scope: scope,
        singleUse: singleUse,
        type: type,
      );
    } else {
      throw const FormatException('Could not validate BearType data!');
    }
  }
}
