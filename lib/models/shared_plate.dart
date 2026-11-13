class SharedPlate {
  final String id;
  final String name;
  final double price;
  final List<String> participantIds;

  const SharedPlate({
    required this.id,
    required this.name,
    required this.price,
    this.participantIds = const [],
  });

  /// Creates a SharedPlate with an auto-generated ID.
  factory SharedPlate.create({
    required String name,
    required double price,
    List<String> participantIds = const [],
  }) {
    final now = DateTime.now().millisecondsSinceEpoch.toString();
    return SharedPlate(
      id: '$now${name.hashCode}',
      name: name,
      price: price,
      participantIds: participantIds,
    );
  }

  /// Cost per person sharing this plate.
  /// Returns 0 if no participants.
  double get costPerPerson =>
      participantIds.isEmpty ? 0 : price / participantIds.length;

  SharedPlate copyWith({
    String? id,
    String? name,
    double? price,
    List<String>? participantIds,
  }) {
    return SharedPlate(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      participantIds: participantIds ?? this.participantIds,
    );
  }

  @override
  String toString() =>
      'SharedPlate(id: $id, name: $name, price: $price, participantIds: $participantIds, costPerPerson: $costPerPerson)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SharedPlate &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
