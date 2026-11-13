class Transaction {
  final String fromPersonId;
  final String fromPersonName;
  final String toPersonId;
  final String toPersonName;
  final double amount;

  const Transaction({
    required this.fromPersonId,
    required this.fromPersonName,
    required this.toPersonId,
    required this.toPersonName,
    required this.amount,
  });

  @override
  String toString() => 'Transaction($fromPersonName -> $toPersonName: $amount)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Transaction &&
          runtimeType == other.runtimeType &&
          fromPersonId == other.fromPersonId &&
          toPersonId == other.toPersonId &&
          amount == other.amount;

  @override
  int get hashCode =>
      fromPersonId.hashCode ^ toPersonId.hashCode ^ amount.hashCode;
}
