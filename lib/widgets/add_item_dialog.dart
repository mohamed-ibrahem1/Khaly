import 'package:flutter/material.dart';

import '../models/order_item.dart';

/// A dialog for adding a personal order item.
///
/// Returns an [OrderItem] on success, or `null` if cancelled.
class AddItemDialog extends StatefulWidget {
  const AddItemDialog._();

  /// Show the add-item dialog and return the created [OrderItem], or `null`.
  static Future<OrderItem?> show(BuildContext context) {
    return showDialog<OrderItem>(
      context: context,
      builder: (_) => const AddItemDialog._(),
    );
  }

  @override
  State<AddItemDialog> createState() => _AddItemDialogState();
}

class _AddItemDialogState extends State<AddItemDialog> {
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    final price = double.tryParse(_priceController.text.trim());
    if (name.isEmpty || price == null || price <= 0) return;

    Navigator.of(context).pop(OrderItem.create(name: name, price: price));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AlertDialog(
      backgroundColor: colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text('إضافة صنف', style: TextStyle(color: colorScheme.onSurface)),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              autofocus: true,
              style: TextStyle(color: colorScheme.onSurface),
              decoration: InputDecoration(
                labelText: 'اسم الصنف',
                labelStyle: TextStyle(
                  color: colorScheme.onSurface.withOpacity(0.6),
                ),
                prefixIcon: Icon(
                  Icons.fastfood_outlined,
                  color: colorScheme.primary,
                ),
                filled: true,
                fillColor: colorScheme.surfaceContainerHighest,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'مطلوب' : null,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _priceController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              style: TextStyle(color: colorScheme.onSurface),
              decoration: InputDecoration(
                labelText: 'السعر',
                labelStyle: TextStyle(
                  color: colorScheme.onSurface.withOpacity(0.6),
                ),
                prefixIcon: Icon(
                  Icons.attach_money,
                  color: colorScheme.primary,
                ),
                suffixText: 'ج.م',
                suffixStyle: TextStyle(color: colorScheme.primary),
                filled: true,
                fillColor: colorScheme.surfaceContainerHighest,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'مطلوب';
                final n = double.tryParse(v.trim());
                if (n == null || n <= 0) return 'أدخل رقم صحيح';
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            'إلغاء',
            style: TextStyle(color: colorScheme.onSurface.withOpacity(0.7)),
          ),
        ),
        FilledButton(
          onPressed: _submit,
          style: FilledButton.styleFrom(backgroundColor: colorScheme.primary),
          child: const Text('إضافة'),
        ),
      ],
    );
  }
}
