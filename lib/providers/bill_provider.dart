import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/order_item.dart';
import '../models/bill_history.dart';
import '../models/person.dart';
import '../models/shared_expense.dart';
import '../models/shared_plate.dart';
import '../models/transaction.dart';
import '../services/storage_service.dart';

/// Main state manager for the "أنا بضيع يا عم صبحي!" bill-splitting app.
///
/// Holds all people, personal items, shared plates, shared expenses,
/// calculated settlements, and frequent-friends persistence.
class BillProvider extends ChangeNotifier {
  // ---------------------------------------------------------------------------
  // State
  // ---------------------------------------------------------------------------
  List<Person> _people = [];
  List<SharedPlate> _sharedPlates = [];
  List<SharedExpense> _sharedExpenses = [];
  List<Transaction> _settlements = [];
  List<String> _frequentFriends = [];
  List<BillHistory> _billHistory = [];

  // ---------------------------------------------------------------------------
  // Getters
  // ---------------------------------------------------------------------------
  List<Person> get people => List.unmodifiable(_people);
  List<SharedPlate> get sharedPlates => List.unmodifiable(_sharedPlates);
  List<SharedExpense> get sharedExpenses => List.unmodifiable(_sharedExpenses);
  List<Transaction> get settlements => List.unmodifiable(_settlements);
  List<String> get frequentFriends => List.unmodifiable(_frequentFriends);
  List<BillHistory> get billHistory => List.unmodifiable(_billHistory);

  // ---------------------------------------------------------------------------
  // Frequent Friends (SharedPreferences)
  // ---------------------------------------------------------------------------

  /// Load frequent friends from local storage.
  Future<void> loadFrequentFriends() async {
    final prefs = await SharedPreferences.getInstance();
    _frequentFriends = prefs.getStringList('frequent_friends') ?? [];
    notifyListeners();
  }

  Future<void> loadBillHistory() async {
    _billHistory = await StorageService.getBillHistory();
    notifyListeners();
  }

  /// Add [name] to the frequent friends list (no duplicates) and persist.
  Future<void> saveFrequentFriend(String name) async {
    if (name.trim().isEmpty) return;
    final trimmed = name.trim();
    if (_frequentFriends.contains(trimmed)) return;

    _frequentFriends.add(trimmed);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('frequent_friends', _frequentFriends);
    notifyListeners();
  }

  /// Remove [name] from the frequent friends list and persist.
  Future<void> removeFrequentFriend(String name) async {
    if (!_frequentFriends.remove(name)) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('frequent_friends', _frequentFriends);
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // People CRUD
  // ---------------------------------------------------------------------------

  /// Add a new person to the session.
  ///
  /// Returns `false` when the name is empty or already used.
  bool addPerson(String name, {double amountPaid = 0}) {
    final trimmedName = name.trim();
    if (trimmedName.isEmpty ||
        _people.any(
          (person) => person.name.toLowerCase() == trimmedName.toLowerCase(),
        )) {
      return false;
    }

    final person = Person.create(name: trimmedName, amountPaid: amountPaid);
    _people.add(person);
    notifyListeners();
    return true;
  }

  /// Remove a person and clean up any references in shared plates.
  void removePerson(String personId) {
    _people.removeWhere((p) => p.id == personId);

    // Remove this person from every shared plate's participant list.
    _sharedPlates = _sharedPlates.map((plate) {
      if (plate.participantIds.contains(personId)) {
        final updated = List<String>.from(plate.participantIds)
          ..remove(personId);
        return plate.copyWith(participantIds: updated);
      }
      return plate;
    }).toList();

    notifyListeners();
  }

  /// Update how much a person has paid.
  void updatePersonPayment(String personId, double amount) {
    final index = _people.indexWhere((p) => p.id == personId);
    if (index == -1) return;
    _people[index] = _people[index].copyWith(amountPaid: amount);
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Personal Items CRUD
  // ---------------------------------------------------------------------------

  /// Add a personal item to a specific person.
  void addPersonalItem(String personId, String itemName, double price) {
    final index = _people.indexWhere((p) => p.id == personId);
    if (index == -1) return;

    final item = OrderItem.create(name: itemName.trim(), price: price);
    final updatedItems = List<OrderItem>.from(_people[index].personalItems)
      ..add(item);
    _people[index] = _people[index].copyWith(personalItems: updatedItems);
    notifyListeners();
  }

  /// Remove a personal item from a specific person.
  void removePersonalItem(String personId, String itemId) {
    final index = _people.indexWhere((p) => p.id == personId);
    if (index == -1) return;

    final updatedItems = List<OrderItem>.from(_people[index].personalItems)
      ..removeWhere((item) => item.id == itemId);
    _people[index] = _people[index].copyWith(personalItems: updatedItems);
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Shared Plates CRUD
  // ---------------------------------------------------------------------------

  /// Add a shared plate split among [participantIds].
  void addSharedPlate(String name, double price, List<String> participantIds) {
    final plate = SharedPlate.create(
      name: name.trim(),
      price: price,
      participantIds: participantIds,
    );
    _sharedPlates.add(plate);
    notifyListeners();
  }

  /// Remove a shared plate by ID.
  void removeSharedPlate(String plateId) {
    _sharedPlates.removeWhere((p) => p.id == plateId);
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Shared Expenses CRUD
  // ---------------------------------------------------------------------------

  /// Add a shared expense (delivery, VAT, etc.) split among ALL people.
  void addSharedExpense(String name, double amount) {
    final expense = SharedExpense.create(name: name.trim(), amount: amount);
    _sharedExpenses.add(expense);
    notifyListeners();
  }

  /// Remove a shared expense by ID.
  void removeSharedExpense(String expenseId) {
    _sharedExpenses.removeWhere((e) => e.id == expenseId);
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Calculation helpers
  // ---------------------------------------------------------------------------

  /// Total of all personal items for a person.
  double getPersonSubtotal(String personId) {
    final person = _people.cast<Person?>().firstWhere(
      (p) => p!.id == personId,
      orElse: () => null,
    );
    return person?.totalPersonalItems ?? 0;
  }

  /// Total of shared-plate shares for a person.
  double getPersonSharedPlatesTotal(String personId) {
    double total = 0;
    for (final plate in _sharedPlates) {
      if (plate.participantIds.contains(personId)) {
        total += plate.costPerPerson;
      }
    }
    return total;
  }

  /// Each person's equal share of all shared expenses.
  double getPersonSharedExpensesShare() {
    if (_people.isEmpty) return 0;
    final totalShared = _sharedExpenses.fold(0.0, (sum, e) => sum + e.amount);
    return totalShared / _people.length;
  }

  /// Total a person owes (personal + shared plates share + shared expenses share).
  double getPersonTotalOwed(String personId) {
    return getPersonSubtotal(personId) +
        getPersonSharedPlatesTotal(personId) +
        getPersonSharedExpensesShare();
  }

  /// Net balance for a person.
  ///   Positive → person owes money.
  ///   Negative → person is owed money (creditor).
  double getPersonNetBalance(String personId) {
    final person = _people.cast<Person?>().firstWhere(
      (p) => p!.id == personId,
      orElse: () => null,
    );
    if (person == null) return 0;
    return getPersonTotalOwed(personId) - person.amountPaid;
  }

  /// Grand total of the entire bill.
  double getTotalBill() {
    double total = 0;

    // Sum all personal items across all people.
    for (final person in _people) {
      total += person.totalPersonalItems;
    }

    // Sum all shared plates.
    for (final plate in _sharedPlates) {
      total += plate.price;
    }

    // Sum all shared expenses.
    for (final expense in _sharedExpenses) {
      total += expense.amount;
    }

    return total;
  }

  // ---------------------------------------------------------------------------
  // Core Settlement Algorithm
  // ---------------------------------------------------------------------------

  /// Calculate the minimum set of transactions to settle all balances.
  ///
  /// Algorithm:
  /// 1. Compute net balance for every person.
  /// 2. Separate into debtors (positive balance → owe money) and
  ///    creditors (negative balance → are owed money).
  /// 3. Sort debtors descending by debt, creditors ascending (most negative
  ///    first = largest creditor first).
  /// 4. Greedily match the largest debtor with the largest creditor:
  ///    settle min(debt, |credit|), reduce both, repeat.
  void calculateSettlements() {
    _settlements = [];

    if (_people.isEmpty) {
      notifyListeners();
      return;
    }

    // Build balance map: personId → netBalance.
    final balances = <String, double>{};
    for (final person in _people) {
      balances[person.id] = getPersonNetBalance(person.id);
    }

    // Helper to look up a person's name.
    String nameOf(String id) => _people
        .firstWhere(
          (p) => p.id == id,
          orElse: () => Person(id: id, name: id),
        )
        .name;

    // Separate into debtors (owe money) and creditors (are owed money).
    // We use a small epsilon to avoid floating-point dust transactions.
    const epsilon = 0.01;

    final debtors = <MapEntry<String, double>>[]; // positive balance
    final creditors =
        <
          MapEntry<String, double>
        >[]; // negative balance (store as positive for ease)

    for (final entry in balances.entries) {
      if (entry.value > epsilon) {
        debtors.add(MapEntry(entry.key, entry.value));
      } else if (entry.value < -epsilon) {
        creditors.add(MapEntry(entry.key, -entry.value)); // store as positive
      }
    }

    // Sort: largest debtor first, largest creditor first.
    debtors.sort((a, b) => b.value.compareTo(a.value));
    creditors.sort((a, b) => b.value.compareTo(a.value));

    // Mutable copies for the greedy loop.
    final debtAmounts = debtors.map((e) => e.value).toList();
    final creditAmounts = creditors.map((e) => e.value).toList();

    int di = 0;
    int ci = 0;

    while (di < debtors.length && ci < creditors.length) {
      final settleAmount = debtAmounts[di] < creditAmounts[ci]
          ? debtAmounts[di]
          : creditAmounts[ci];

      if (settleAmount > epsilon) {
        _settlements.add(
          Transaction(
            fromPersonId: debtors[di].key,
            fromPersonName: nameOf(debtors[di].key),
            toPersonId: creditors[ci].key,
            toPersonName: nameOf(creditors[ci].key),
            amount: double.parse(settleAmount.toStringAsFixed(2)),
          ),
        );
      }

      debtAmounts[di] -= settleAmount;
      creditAmounts[ci] -= settleAmount;

      if (debtAmounts[di] < epsilon) di++;
      if (creditAmounts[ci] < epsilon) ci++;
    }

    notifyListeners();
  }

  Future<void> saveCurrentBillToHistory() async {
    if (_people.isEmpty) return;
    final bill = BillHistory(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      date: DateTime.now(),
      people: _people
          .map(
            (person) => person.copyWith(
              personalItems: List.unmodifiable(person.personalItems),
            ),
          )
          .toList(),
      sharedPlates: List.unmodifiable(_sharedPlates),
      sharedExpenses: List.unmodifiable(_sharedExpenses),
      settlements: List.unmodifiable(_settlements),
      totalBill: getTotalBill(),
    );
    await StorageService.saveBillHistory(bill);
    _billHistory = await StorageService.getBillHistory();
    notifyListeners();
  }

  void loadBillFromHistory(BillHistory bill) {
    _people = bill.people;
    _sharedPlates = bill.sharedPlates;
    _sharedExpenses = bill.sharedExpenses;
    _settlements = bill.settlements;
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Reset
  // ---------------------------------------------------------------------------

  /// Clear all session data (does NOT clear frequent friends).
  void resetSession() {
    _people = [];
    _sharedPlates = [];
    _sharedExpenses = [];
    _settlements = [];
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Share Text
  // ---------------------------------------------------------------------------

  /// Generate a formatted Arabic text summary suitable for sharing via
  /// WhatsApp or any messenger.
  String generateShareText() {
    final buffer = StringBuffer();

    buffer.writeln('🧾 *أنا بضيع يا عم صبحي!*');
    buffer.writeln('━━━━━━━━━━━━━━━━━━━━');
    buffer.writeln();

    if (_people.isEmpty) {
      buffer.writeln('مفيش حد في الفاتورة! 🤷‍♂️');
      return buffer.toString();
    }

    // --- Per-person breakdown ---
    buffer.writeln('👥 *الأشخاص:*');
    for (final person in _people) {
      buffer.writeln();
      buffer.writeln('• *${person.name}*');

      if (person.personalItems.isNotEmpty) {
        buffer.writeln('  🍽️ طلبات شخصية:');
        for (final item in person.personalItems) {
          buffer.writeln(
            '    - ${item.name}: ${item.price.toStringAsFixed(2)} جنيه',
          );
        }
      }

      final sharedPlatesTotal = getPersonSharedPlatesTotal(person.id);
      if (sharedPlatesTotal > 0) {
        buffer.writeln(
          '  🍕 نصيبه من الأطباق المشتركة: ${sharedPlatesTotal.toStringAsFixed(2)} جنيه',
        );
      }

      final sharedExpShare = getPersonSharedExpensesShare();
      if (sharedExpShare > 0) {
        buffer.writeln(
          '  💰 نصيبه من المصاريف المشتركة: ${sharedExpShare.toStringAsFixed(2)} جنيه',
        );
      }

      final totalOwed = getPersonTotalOwed(person.id);
      buffer.writeln(
        '  📊 *الإجمالي المطلوب: ${totalOwed.toStringAsFixed(2)} جنيه*',
      );
      buffer.writeln(
        '  💵 المدفوع: ${person.amountPaid.toStringAsFixed(2)} جنيه',
      );

      final net = getPersonNetBalance(person.id);
      if (net > 0.01) {
        buffer.writeln('  ⚠️ عليه: ${net.toStringAsFixed(2)} جنيه');
      } else if (net < -0.01) {
        buffer.writeln('  ✅ له: ${(-net).toStringAsFixed(2)} جنيه');
      } else {
        buffer.writeln('  ✅ متساوي!');
      }
    }

    // --- Shared plates ---
    if (_sharedPlates.isNotEmpty) {
      buffer.writeln();
      buffer.writeln('━━━━━━━━━━━━━━━━━━━━');
      buffer.writeln('🍕 *أطباق مشتركة:*');
      for (final plate in _sharedPlates) {
        final names = plate.participantIds
            .map(
              (id) =>
                  _people
                      .cast<Person?>()
                      .firstWhere((p) => p!.id == id, orElse: () => null)
                      ?.name ??
                  '؟',
            )
            .join('، ');
        buffer.writeln(
          '  - ${plate.name}: ${plate.price.toStringAsFixed(2)} جنيه (بين: $names)',
        );
      }
    }

    // --- Shared expenses ---
    if (_sharedExpenses.isNotEmpty) {
      buffer.writeln();
      buffer.writeln('💸 *مصاريف مشتركة:*');
      for (final expense in _sharedExpenses) {
        buffer.writeln(
          '  - ${expense.name}: ${expense.amount.toStringAsFixed(2)} جنيه',
        );
      }
    }

    // --- Total ---
    buffer.writeln();
    buffer.writeln('━━━━━━━━━━━━━━━━━━━━');
    buffer.writeln(
      '💰 *إجمالي الفاتورة: ${getTotalBill().toStringAsFixed(2)} جنيه*',
    );

    // --- Settlements ---
    if (_settlements.isNotEmpty) {
      buffer.writeln();
      buffer.writeln('━━━━━━━━━━━━━━━━━━━━');
      buffer.writeln('🔄 *التسويات:*');
      for (final tx in _settlements) {
        buffer.writeln(
          '  💸 ${tx.fromPersonName} ➜ ${tx.toPersonName}: ${tx.amount.toStringAsFixed(2)} جنيه',
        );
      }
    }

    buffer.writeln();
    buffer.writeln('━━━━━━━━━━━━━━━━━━━━');
    buffer.writeln('تم الحساب بواسطة تطبيق أنا بضيع يا عم صبحي! 🎉');

    return buffer.toString();
  }
}
