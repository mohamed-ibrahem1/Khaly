import 'package:flutter/material.dart';

import '../models/transaction.dart';

/// A card that displays a settlement transaction between two people.
///
/// Shows "fromName يدفع amount ج.م إلى toName" with an animated arrow icon
/// and a colourful layout.
class SettlementCard extends StatefulWidget {
  const SettlementCard({super.key, required this.transaction});

  /// The settlement transaction to display.
  final Transaction transaction;

  @override
  State<SettlementCard> createState() => _SettlementCardState();
}

class _SettlementCardState extends State<SettlementCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _arrowController;
  late final Animation<double> _arrowAnimation;

  @override
  void initState() {
    super.initState();
    _arrowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _arrowAnimation = Tween<double>(begin: -6, end: 6).animate(
      CurvedAnimation(parent: _arrowController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _arrowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final primaryColor = colorScheme.primary;
    final secondaryColor = colorScheme.secondary;

    return Card(
      color: colorScheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            // ── From person ──
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    backgroundColor: colorScheme.error.withOpacity(0.15),
                    child: Text(
                      widget.transaction.fromPersonName.isNotEmpty
                          ? widget.transaction.fromPersonName[0]
                          : '?',
                      style: TextStyle(
                        color: colorScheme.error,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    widget.transaction.fromPersonName,
                    style: TextStyle(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // ── Animated arrow + amount ──
            Column(
              children: [
                AnimatedBuilder(
                  animation: _arrowAnimation,
                  builder: (_, child) => Transform.translate(
                    offset: Offset(_arrowAnimation.value, 0),
                    child: child,
                  ),
                  child: Icon(
                    Icons.arrow_forward_rounded,
                    color: secondaryColor,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${widget.transaction.amount.toStringAsFixed(2)} ج.م',
                    style: TextStyle(
                      color: primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
              ],
            ),

            // ── To person ──
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    backgroundColor: primaryColor.withOpacity(0.15),
                    child: Text(
                      widget.transaction.toPersonName.isNotEmpty
                          ? widget.transaction.toPersonName[0]
                          : '?',
                      style: TextStyle(
                        color: primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    widget.transaction.toPersonName,
                    style: TextStyle(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
