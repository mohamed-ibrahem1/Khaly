import 'package:flutter_test/flutter_test.dart';

import 'package:khaly/providers/bill_provider.dart';

void main() {
  test('splits shared plates and settles net balances', () {
    final provider = BillProvider();
    provider.addPerson('أحمد', amountPaid: 150);
    provider.addPerson('علي');

    final ahmedId = provider.people.first.id;
    final aliId = provider.people.last.id;
    provider.addPersonalItem(ahmedId, 'برجر', 100);
    provider.addSharedPlate('بيتزا', 40, [ahmedId, aliId]);
    provider.addSharedExpense('توصيل', 20);
    provider.calculateSettlements();

    expect(provider.getPersonTotalOwed(ahmedId), 130);
    expect(provider.getPersonTotalOwed(aliId), 30);
    expect(provider.settlements, hasLength(1));
    expect(provider.settlements.single.fromPersonId, aliId);
    expect(provider.settlements.single.toPersonId, ahmedId);
    expect(provider.settlements.single.amount, 20);
  });

  test('does not divide shared expenses by zero people', () {
    final provider = BillProvider();
    provider.addSharedExpense('توصيل', 20);

    expect(provider.getPersonSharedExpensesShare(), 0);
    expect(provider.getTotalBill(), 20);
    provider.calculateSettlements();
    expect(provider.settlements, isEmpty);
  });

  test('rejects duplicate person names case-insensitively', () {
    final provider = BillProvider();

    expect(provider.addPerson('Ahmed'), isTrue);
    expect(provider.addPerson(' ahmed '), isFalse);
    expect(provider.people, hasLength(1));
  });
}
