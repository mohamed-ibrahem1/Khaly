class OrderItem {
  final String id;
  final String name;
  final double price;

  const OrderItem({required this.id, required this.name, required this.price});

  /// Creates an OrderItem with an auto-generated ID.
  factory OrderItem.create({required String name, required double price}) {
    final now = DateTime.now().millisecondsSinceEpoch.toString();
    return OrderItem(id: '$now${name.hashCode}', name: name, price: price);
  }

  OrderItem copyWith({String? id, String? name, double? price}) {
    return OrderItem(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
    );
  }

  @override
  String toString() => 'OrderItem(id: $id, name: $name, price: $price)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OrderItem && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
