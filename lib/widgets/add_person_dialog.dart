import 'package:flutter/material.dart';

/// A dialog for adding a new person to the bill-splitting session.
///
/// Provides a name field with frequent-friends chip suggestions and an
/// optional "amount paid" field.
///
/// Returns `{name: String, amountPaid: double}` on success, or `null`.
class AddPersonDialog extends StatefulWidget {
  const AddPersonDialog._({
    required this.frequentFriends,
    required this.onRemoveFriend,
  });

  /// List of previously-used friend names, shown as tappable chips.
  final List<String> frequentFriends;
  final ValueChanged<String> onRemoveFriend;

  /// Show the add-person dialog.
  ///
  /// Returns a [Map] with keys `name` ([String]) and `amountPaid` ([double]),
  /// or `null` if cancelled.
  static Future<Map<String, dynamic>?> show(
    BuildContext context, {
    List<String> frequentFriends = const [],
    ValueChanged<String>? onRemoveFriend,
  }) {
    return showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => AddPersonDialog._(
        frequentFriends: frequentFriends,
        onRemoveFriend: onRemoveFriend ?? (_) {},
      ),
    );
  }

  @override
  State<AddPersonDialog> createState() => _AddPersonDialogState();
}

class _AddPersonDialogState extends State<AddPersonDialog> {
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  late List<String> _visibleFriends;

  @override
  void initState() {
    super.initState();
    _visibleFriends = List<String>.from(widget.frequentFriends);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _selectFriend(String name) {
    _nameController.text = name;
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    final amountPaid = double.tryParse(_amountController.text.trim()) ?? 0.0;

    Navigator.of(context).pop({'name': name, 'amountPaid': amountPaid});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AlertDialog(
      backgroundColor: colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text('إضافة شخص', style: TextStyle(color: colorScheme.onSurface)),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Frequent friends chips ──
              if (_visibleFriends.isNotEmpty) ...[
                Text(
                  'أصدقاء سابقين:',
                  style: TextStyle(
                    color: colorScheme.onSurface.withOpacity(0.6),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: _visibleFriends.map((friend) {
                    return InputChip(
                      avatar: Icon(
                        Icons.person,
                        size: 18,
                        color: colorScheme.primary,
                      ),
                      label: Text(friend),
                      labelStyle: TextStyle(color: colorScheme.onSurface),
                      backgroundColor: colorScheme.surfaceContainerHighest,
                      side: BorderSide(
                        color: colorScheme.primary.withOpacity(0.55),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 6,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      onPressed: () => _selectFriend(friend),
                      deleteIcon: const Icon(Icons.close, size: 18),
                      onDeleted: () {
                        setState(() {
                          _visibleFriends.remove(friend);
                        });
                        widget.onRemoveFriend(friend);
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 14),
              ],

              // ── Name field ──
              TextFormField(
                controller: _nameController,
                autofocus: true,
                style: TextStyle(color: colorScheme.onSurface),
                decoration: InputDecoration(
                  labelText: 'الاسم',
                  labelStyle: TextStyle(
                    color: colorScheme.onSurface.withOpacity(0.6),
                  ),
                  prefixIcon: Icon(
                    Icons.person_outline,
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

              // ── Amount paid field ──
              TextFormField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                style: TextStyle(color: colorScheme.onSurface),
                decoration: InputDecoration(
                  labelText: 'المبلغ المدفوع (اختياري)',
                  labelStyle: TextStyle(
                    color: colorScheme.onSurface.withOpacity(0.6),
                  ),
                  prefixIcon: Icon(
                    Icons.payments_outlined,
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
              ),
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
