import 'order_item.dart';

class Person {
  final String id;
  final String name;
  final double amountPaid;
  final List<OrderItem> personalItems;

  const Person({
    required this.id,
    required this.name,
    this.amountPaid = 0,
    this.personalItems = const [],
  });

  /// Creates a Person with an auto-generated ID.
  factory Person.create({
    required String name,
    double amountPaid = 0,
    List<OrderItem> personalItems = const [],
  }) {
    final now = DateTime.now().millisecondsSinceEpoch.toString();
    return Person(
      id: '$now${name.hashCode}',
      name: name,
      amountPaid: amountPaid,
      personalItems: personalItems,
    );
  }

  /// Total cost of all personal items for this person.
  double get totalPersonalItems =>
      personalItems.fold(0.0, (sum, item) => sum + item.price);

  Person copyWith({
    String? id,
    String? name,
    double? amountPaid,
    List<OrderItem>? personalItems,
  }) {
    return Person(
      id: id ?? this.id,
      name: name ?? this.name,
      amountPaid: amountPaid ?? this.amountPaid,
      personalItems: personalItems ?? this.personalItems,
    );
  }

  @override
  String toString() =>
      'Person(id: $id, name: $name, amountPaid: $amountPaid, personalItems: $personalItems)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Person && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
