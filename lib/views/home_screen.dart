import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/bill_provider.dart';
import '../widgets/person_card.dart';
import '../widgets/shared_plate_card.dart';
import '../widgets/shared_expense_card.dart';
import '../widgets/add_person_dialog.dart';
import '../widgets/add_shared_plate_dialog.dart';
import '../widgets/add_item_dialog.dart';
import 'results_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'خلّى',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 35),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_forever),
            tooltip: 'إعادة تعيين',
            onPressed: () {
              _showResetConfirmation(context);
            },
          ),
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'احسب',
            onPressed: () => _calculateAndNavigate(context),
          ),
        ],
      ),
      body: Consumer<BillProvider>(
        builder: (context, provider, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ──── الأشخاص ────
                _buildSectionHeader(
                  context,
                  title: 'الأشخاص 👥',
                  onAdd: () => _showAddPersonDialog(context),
                ),
                if (provider.people.isEmpty)
                  _buildEmptyHint('اضغط + لإضافة شخص'),
                ...provider.people.map(
                  (person) => PersonCard(
                    person: person,
                    onDelete: () => provider.removePerson(person.id),
                    onAddItem: () async {
                      final item = await AddItemDialog.show(context);
                      if (item != null) {
                        provider.addPersonalItem(
                          person.id,
                          item.name,
                          item.price,
                        );
                      }
                    },
                    onRemoveItem: (itemId) =>
                        provider.removePersonalItem(person.id, itemId),
                    onUpdatePayment: (amount) =>
                        provider.updatePersonPayment(person.id, amount),
                  ),
                ),
                const SizedBox(height: 20),

                // ──── الأطباق المشتركة ────
                _buildSectionHeader(
                  context,
                  title: 'الأطباق المشتركة 🍽️',
                  onAdd: provider.people.isEmpty
                      ? null
                      : () => _showAddSharedPlateDialog(context),
                ),
                if (provider.sharedPlates.isEmpty)
                  _buildEmptyHint('اضغط + لإضافة طبق مشترك'),
                ...provider.sharedPlates.map(
                  (plate) => SharedPlateCard(
                    plate: plate,
                    allPeople: provider.people,
                    onDelete: () => provider.removeSharedPlate(plate.id),
                  ),
                ),
                const SizedBox(height: 20),

                // ──── المصاريف المشتركة ────
                _buildSectionHeader(
                  context,
                  title: 'المصاريف المشتركة 🛵',
                  onAdd: () => _showAddSharedExpenseDialog(context),
                ),
                if (provider.sharedExpenses.isEmpty)
                  _buildEmptyHint('توصيل، ضريبة، بقشيش...'),
                ...provider.sharedExpenses.map(
                  (expense) => SharedExpenseCard(
                    expense: expense,
                    numberOfPeople: provider.people.length,
                    onDelete: () => provider.removeSharedExpense(expense.id),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: Consumer<BillProvider>(
        builder: (context, provider, _) => SafeArea(
          minimum: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: SizedBox(
            height: 56,
            child: ElevatedButton(
              onPressed: provider.people.isEmpty
                  ? null
                  : () => _calculateAndNavigate(context),
              style: ElevatedButton.styleFrom(
                textStyle: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              child: const Text('احسب'),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context, {
    required String title,
    VoidCallback? onAdd,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          if (onAdd != null)
            SizedBox(
              width: 45,
              height: 45,
              child: IconButton.filled(
                icon: const Icon(Icons.add, size: 30),
                tooltip: 'إضافة',
                style: IconButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: onAdd,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyHint(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Center(
        child: Text(
          text,
          style: const TextStyle(color: Colors.white38, fontSize: 14),
        ),
      ),
    );
  }

  Future<void> _showAddPersonDialog(BuildContext context) async {
    final provider = context.read<BillProvider>();
    final result = await AddPersonDialog.show(
      context,
      frequentFriends: provider.frequentFriends,
    );
    if (result != null) {
      final added = provider.addPerson(
        result['name'] as String,
        amountPaid: result['amountPaid'] as double,
      );
      if (added) {
        provider.saveFrequentFriend(result['name'] as String);
      } else if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('الاسم موجود بالفعل في الفاتورة')),
        );
      }
    }
  }

  Future<void> _showAddSharedPlateDialog(BuildContext context) async {
    final provider = context.read<BillProvider>();
    final result = await AddSharedPlateDialog.show(
      context,
      people: provider.people,
    );
    if (result != null) {
      provider.addSharedPlate(
        result['name'] as String,
        result['price'] as double,
        List<String>.from(result['participantIds'] as List),
      );
    }
  }

  Future<void> _showAddSharedExpenseDialog(BuildContext context) async {
    final provider = context.read<BillProvider>();
    final nameController = TextEditingController();
    final amountController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('إضافة مصروف مشترك'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'اسم المصروف',
                  hintText: 'مثال: توصيل، ضريبة...',
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'مطلوب' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: amountController,
                decoration: const InputDecoration(
                  labelText: 'المبلغ',
                  hintText: '0.00',
                  suffixText: 'ج.م',
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'مطلوب';
                  if (double.tryParse(v) == null) return 'رقم غير صالح';
                  if (double.parse(v) <= 0) return 'يجب أن يكون أكبر من صفر';
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(ctx, {
                  'name': nameController.text.trim(),
                  'amount': double.parse(amountController.text.trim()),
                });
              }
            },
            child: const Text('إضافة'),
          ),
        ],
      ),
    );

    if (result != null) {
      provider.addSharedExpense(
        result['name'] as String,
        result['amount'] as double,
      );
    }
  }

  void _showResetConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('إعادة تعيين؟'),
        content: const Text('هيتم مسح كل البيانات. متأكد؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('لا'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () {
              context.read<BillProvider>().resetSession();
              Navigator.pop(ctx);
            },
            child: const Text('أيوه امسح'),
          ),
        ],
      ),
    );
  }

  void _calculateAndNavigate(BuildContext context) {
    final provider = context.read<BillProvider>();
    if (provider.people.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('ضيف أشخاص الأول! 👥')));
      return;
    }
    provider.calculateSettlements();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ResultsScreen()),
    );
  }
}
