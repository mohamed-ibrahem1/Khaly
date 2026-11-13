import 'package:flutter/material.dart';

import '../models/person.dart';
import '../models/shared_plate.dart';

/// A card that displays a shared plate: its name, price, participants
/// and the cost per person.
class SharedPlateCard extends StatelessWidget {
  const SharedPlateCard({
    super.key,
    required this.plate,
    required this.allPeople,
    required this.onDelete,
  });

  /// The shared plate model.
  final SharedPlate plate;

  /// All people in the session (used to resolve participant names).
  final List<Person> allPeople;

  /// Called when the delete button is tapped.
  final VoidCallback onDelete;

  /// Resolve a person ID to a display name.
  String _nameOf(String id) {
    for (final p in allPeople) {
      if (p.id == id) return p.name;
    }
    return '؟';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final primaryColor = colorScheme.primary;
    final secondaryColor = colorScheme.secondary;

    final participantNames = plate.participantIds.map(_nameOf).join('، ');

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
            // ── Header: plate name + delete ──
            Row(
              children: [
                Icon(Icons.restaurant, color: secondaryColor, size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    plate.name,
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

            // ── Price ──
            Row(
              children: [
                Text(
                  'السعر: ',
                  style: TextStyle(
                    color: colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
                Text(
                  '${plate.price.toStringAsFixed(2)} ج.م',
                  style: TextStyle(
                    color: primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 6),

            // ── Participants ──
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.people_outline,
                  size: 16,
                  color: colorScheme.onSurface.withOpacity(0.5),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    participantNames.isNotEmpty
                        ? participantNames
                        : 'لا يوجد مشاركين',
                    style: TextStyle(
                      color: colorScheme.onSurface.withOpacity(0.8),
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 6),

            // ── Cost per person ──
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
                  'للفرد: ${plate.costPerPerson.toStringAsFixed(2)} ج.م',
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
