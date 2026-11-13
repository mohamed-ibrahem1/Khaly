import 'package:flutter/material.dart';

import '../models/person.dart';

/// A dialog for adding a shared plate.
///
/// Shows name and price fields plus multi-select checkboxes for participants.
///
/// Returns `{name: String, price: double, participantIds: List<String>}`
/// on success, or `null` if cancelled.
class AddSharedPlateDialog extends StatefulWidget {
  const AddSharedPlateDialog._({required this.people});

  /// All people in the current session.
  final List<Person> people;

  /// Show the add-shared-plate dialog.
  ///
  /// Returns a [Map] with keys `name`, `price`, `participantIds`, or `null`.
  static Future<Map<String, dynamic>?> show(
    BuildContext context, {
    required List<Person> people,
  }) {
    return showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => AddSharedPlateDialog._(people: people),
    );
  }

  @override
  State<AddSharedPlateDialog> createState() => _AddSharedPlateDialogState();
}

class _AddSharedPlateDialogState extends State<AddSharedPlateDialog> {
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final Set<String> _selectedIds = {};

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _toggleParticipant(String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
    });
  }

  void _selectAll() {
    setState(() {
      if (_selectedIds.length == widget.people.length) {
        _selectedIds.clear();
      } else {
        _selectedIds.addAll(widget.people.map((p) => p.id));
      }
    });
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    final price = double.tryParse(_priceController.text.trim());
    if (name.isEmpty || price == null || price <= 0) return;
    if (_selectedIds.isEmpty) return;

    Navigator.of(context).pop({
      'name': name,
      'price': price,
      'participantIds': _selectedIds.toList(),
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final allSelected = _selectedIds.length == widget.people.length;

    return AlertDialog(
      backgroundColor: colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(
        'إضافة طبق مشترك',
        style: TextStyle(color: colorScheme.onSurface),
      ),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Name ──
              TextFormField(
                controller: _nameController,
                autofocus: true,
                style: TextStyle(color: colorScheme.onSurface),
                decoration: InputDecoration(
                  labelText: 'اسم الطبق',
                  labelStyle: TextStyle(
                    color: colorScheme.onSurface.withOpacity(0.6),
                  ),
                  prefixIcon: Icon(
                    Icons.restaurant,
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

              // ── Price ──
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

              const SizedBox(height: 16),

              // ── Participants header ──
              Row(
                children: [
                  Text(
                    'المشاركين:',
                    style: TextStyle(
                      color: colorScheme.onSurface.withOpacity(0.8),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: _selectAll,
                    icon: Icon(
                      allSelected ? Icons.deselect : Icons.select_all,
                      size: 18,
                    ),
                    label: Text(allSelected ? 'إلغاء الكل' : 'اختيار الكل'),
                    style: TextButton.styleFrom(
                      foregroundColor: colorScheme.secondary,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 4),

              // ── Participants checkboxes ──
              if (widget.people.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    'لا يوجد أشخاص بعد!',
                    style: TextStyle(
                      color: colorScheme.onSurface.withOpacity(0.5),
                    ),
                  ),
                )
              else
                ...widget.people.map((person) {
                  final selected = _selectedIds.contains(person.id);
                  return CheckboxListTile(
                    value: selected,
                    onChanged: (_) => _toggleParticipant(person.id),
                    title: Text(
                      person.name,
                      style: TextStyle(color: colorScheme.onSurface),
                    ),
                    activeColor: colorScheme.primary,
                    checkColor: colorScheme.onPrimary,
                    controlAffinity: ListTileControlAffinity.leading,
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  );
                }),
            ],
          ),
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
