import 'order_item.dart';
import 'person.dart';
import 'shared_expense.dart';
import 'shared_plate.dart';
import 'transaction.dart';

class BillHistory {
  final String id;
  final DateTime date;
  final List<Person> people;
  final List<SharedPlate> sharedPlates;
  final List<SharedExpense> sharedExpenses;
  final List<Transaction> settlements;
  final double totalBill;

  const BillHistory({
    required this.id,
    required this.date,
    required this.people,
    required this.sharedPlates,
    required this.sharedExpenses,
    required this.settlements,
    required this.totalBill,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'date': date.toIso8601String(),
    'people': people
        .map(
          (person) => {
            'id': person.id,
            'name': person.name,
            'amountPaid': person.amountPaid,
            'personalItems': person.personalItems
                .map(
                  (item) => {
                    'id': item.id,
                    'name': item.name,
                    'price': item.price,
                  },
                )
                .toList(),
          },
        )
        .toList(),
    'sharedPlates': sharedPlates
        .map(
          (plate) => {
            'id': plate.id,
            'name': plate.name,
            'price': plate.price,
            'participantIds': plate.participantIds,
          },
        )
        .toList(),
    'sharedExpenses': sharedExpenses
        .map(
          (expense) => {
            'id': expense.id,
            'name': expense.name,
            'amount': expense.amount,
          },
        )
        .toList(),
    'settlements': settlements
        .map(
          (transaction) => {
            'fromPersonId': transaction.fromPersonId,
            'fromPersonName': transaction.fromPersonName,
            'toPersonId': transaction.toPersonId,
            'toPersonName': transaction.toPersonName,
            'amount': transaction.amount,
          },
        )
        .toList(),
    'totalBill': totalBill,
  };

  factory BillHistory.fromMap(Map<String, dynamic> map) {
    final people = (map['people'] as List<dynamic>? ?? []).map((value) {
      final person = Map<String, dynamic>.from(value as Map);
      final items = (person['personalItems'] as List<dynamic>? ?? []).map((
        value,
      ) {
        final item = Map<String, dynamic>.from(value as Map);
        return OrderItem(
          id: item['id'] as String,
          name: item['name'] as String,
          price: (item['price'] as num).toDouble(),
        );
      }).toList();
      return Person(
        id: person['id'] as String,
        name: person['name'] as String,
        amountPaid: (person['amountPaid'] as num).toDouble(),
        personalItems: items,
      );
    }).toList();

    return BillHistory(
      id: map['id'] as String,
      date: DateTime.parse(map['date'] as String),
      people: people,
      sharedPlates: (map['sharedPlates'] as List<dynamic>? ?? []).map((value) {
        final plate = Map<String, dynamic>.from(value as Map);
        return SharedPlate(
          id: plate['id'] as String,
          name: plate['name'] as String,
          price: (plate['price'] as num).toDouble(),
          participantIds: List<String>.from(plate['participantIds'] as List),
        );
      }).toList(),
      sharedExpenses: (map['sharedExpenses'] as List<dynamic>? ?? []).map((
        value,
      ) {
        final expense = Map<String, dynamic>.from(value as Map);
        return SharedExpense(
          id: expense['id'] as String,
          name: expense['name'] as String,
          amount: (expense['amount'] as num).toDouble(),
        );
      }).toList(),
      settlements: (map['settlements'] as List<dynamic>? ?? []).map((value) {
        final transaction = Map<String, dynamic>.from(value as Map);
        return Transaction(
          fromPersonId: transaction['fromPersonId'] as String,
          fromPersonName: transaction['fromPersonName'] as String,
          toPersonId: transaction['toPersonId'] as String,
          toPersonName: transaction['toPersonName'] as String,
          amount: (transaction['amount'] as num).toDouble(),
        );
      }).toList(),
      totalBill: (map['totalBill'] as num).toDouble(),
    );
  }
}
