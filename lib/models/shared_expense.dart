class SharedExpense {
  final String id;
  final String name;
  final double amount;

  const SharedExpense({
    required this.id,
    required this.name,
    required this.amount,
  });

  /// Creates a SharedExpense with an auto-generated ID.
  factory SharedExpense.create({required String name, required double amount}) {
    final now = DateTime.now().millisecondsSinceEpoch.toString();
    return SharedExpense(
      id: '$now${name.hashCode}',
      name: name,
      amount: amount,
    );
  }

  SharedExpense copyWith({String? id, String? name, double? amount}) {
    return SharedExpense(
      id: id ?? this.id,
      name: name ?? this.name,
      amount: amount ?? this.amount,
    );
  }

  @override
  String toString() => 'SharedExpense(id: $id, name: $name, amount: $amount)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SharedExpense &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
