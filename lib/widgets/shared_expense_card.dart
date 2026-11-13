import 'package:flutter/material.dart';

import '../models/shared_expense.dart';

/// A card that displays a shared expense (e.g. delivery, VAT)
/// showing the expense name, amount, and how many people it is split among.
class SharedExpenseCard extends StatelessWidget {
  const SharedExpenseCard({
    super.key,
    required this.expense,
    required this.numberOfPeople,
    required this.onDelete,
  });

  /// The shared expense model.
  final SharedExpense expense;

  /// Total number of people the expense is divided among.
  final int numberOfPeople;

  /// Called when the delete button is tapped.
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final primaryColor = colorScheme.primary;
    final secondaryColor = colorScheme.secondary;

    final perPerson = numberOfPeople > 0
        ? (expense.amount / numberOfPeople).toStringAsFixed(2)
        : '—';

    return Card(
      color: colorScheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header: name + delete ──
            Row(
              children: [
                Icon(Icons.receipt_long, color: secondaryColor, size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    expense.name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.delete_outline, color: colorScheme.error),
                  tooltip: 'حذف',
                  onPressed: onDelete,
                ),
              ],
            ),

            const SizedBox(height: 8),

            // ── Amount ──
            Row(
              children: [
                Text(
                  'المبلغ: ',
                  style: TextStyle(
                    color: colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
                Text(
                  '${expense.amount.toStringAsFixed(2)} ج.م',
                  style: TextStyle(
                    color: primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 6),

            // ── Split info ──
            Row(
              children: [
                Icon(
                  Icons.people_outline,
                  size: 16,
                  color: colorScheme.onSurface.withOpacity(0.5),
                ),
                const SizedBox(width: 6),
                Text(
                  'مقسم على $numberOfPeople أشخاص',
                  style: TextStyle(
                    color: colorScheme.onSurface.withOpacity(0.8),
                    fontSize: 13,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 6),

            // ── Per person ──
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'للفرد: $perPerson ج.م',
                  style: TextStyle(
                    color: primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
