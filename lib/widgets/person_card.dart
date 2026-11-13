import 'package:flutter/material.dart';

import '../models/person.dart';

/// A dark-themed card that displays one person in the bill-splitting session.
///
/// Shows the person's name, amount paid, list of personal items, and subtotal.
/// Provides action buttons for adding items, editing payment and deleting.
class PersonCard extends StatelessWidget {
  const PersonCard({
    super.key,
    required this.person,
    required this.onDelete,
    required this.onAddItem,
    required this.onRemoveItem,
    required this.onUpdatePayment,
  });

  /// The person model to display.
  final Person person;

  /// Called when the delete button is tapped.
  final VoidCallback onDelete;

  /// Called when the "add item" button is tapped.
  final VoidCallback onAddItem;

  /// Called when a personal item is removed.
  final Function(String) onRemoveItem;

  /// Called when the user updates the amount this person paid.
  final Function(double) onUpdatePayment;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final primaryColor = colorScheme.primary; // mint green accent

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
                CircleAvatar(
                  backgroundColor: primaryColor.withOpacity(0.15),
                  child: Text(
                    person.name.isNotEmpty ? person.name[0] : '?',
                    style: TextStyle(
                      color: primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    person.name,
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

            // ── Amount paid ──
            InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () => _showPaymentDialog(context),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Icon(
                      Icons.payments_outlined,
                      size: 18,
                      color: primaryColor,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'دفع: ',
                      style: TextStyle(
                        color: colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                    Text(
                      '${person.amountPaid.toStringAsFixed(2)} ج.م',
                      style: TextStyle(
                        color: primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.edit,
                      size: 14,
                      color: colorScheme.onSurface.withOpacity(0.4),
                    ),
                  ],
                ),
              ),
            ),

            // ── Personal items list ──
            if (person.personalItems.isNotEmpty) ...[
              const SizedBox(height: 8),
              const Divider(height: 1),
              const SizedBox(height: 8),
              Text(
                'الطلبات الشخصية:',
                style: TextStyle(
                  color: colorScheme.onSurface.withOpacity(0.6),
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 4),
              ...person.personalItems.map(
                (item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    children: [
                      const Text('• ', style: TextStyle(color: Colors.white70)),
                      Expanded(
                        child: Text(
                          item.name,
                          style: TextStyle(color: colorScheme.onSurface),
                        ),
                      ),
                      Text(
                        '${item.price.toStringAsFixed(2)} ج.م',
                        style: TextStyle(
                          color: primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.close,
                          size: 18,
                          color: colorScheme.error,
                        ),
                        tooltip: 'حذف الصنف',
                        onPressed: () => onRemoveItem(item.id),
                        visualDensity: VisualDensity.compact,
                      ),
                    ],
                  ),
                ),
              ),
            ],

            // ── Subtotal ──
            if (person.personalItems.isNotEmpty) ...[
              const SizedBox(height: 6),
              const Divider(height: 1),
              const SizedBox(height: 6),
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: Text(
                  'إجمالي: ${person.totalPersonalItems.toStringAsFixed(2)} ج.م',
                  style: TextStyle(
                    color: primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
            ],

            const SizedBox(height: 8),

            // ── Add item button ──
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onAddItem,
                icon: const Icon(Icons.add_circle_outline, size: 18),
                label: const Text('إضافة صنف'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: primaryColor,
                  side: BorderSide(color: primaryColor.withOpacity(0.5)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Shows a small dialog to edit the payment amount.
  Future<void> _showPaymentDialog(BuildContext context) async {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final controller = TextEditingController(
      text: person.amountPaid.toStringAsFixed(2),
    );

    final result = await showDialog<double>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'تعديل المبلغ المدفوع',
          style: TextStyle(color: colorScheme.onSurface),
        ),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          autofocus: true,
          style: TextStyle(color: colorScheme.onSurface),
          decoration: InputDecoration(
            labelText: 'المبلغ',
            labelStyle: TextStyle(
              color: colorScheme.onSurface.withOpacity(0.6),
            ),
            suffixText: 'ج.م',
            suffixStyle: TextStyle(color: colorScheme.primary),
            filled: true,
            fillColor: colorScheme.surfaceContainerHighest,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'إلغاء',
              style: TextStyle(color: colorScheme.onSurface.withOpacity(0.7)),
            ),
          ),
          FilledButton(
            onPressed: () {
              final value = double.tryParse(controller.text);
              if (value != null && value >= 0) {
                Navigator.of(ctx).pop(value);
              }
            },
            style: FilledButton.styleFrom(backgroundColor: colorScheme.primary),
            child: const Text('حفظ'),
          ),
        ],
      ),
    );

    if (result != null) {
      onUpdatePayment(result);
    }
  }
}
