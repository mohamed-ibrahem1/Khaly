import 'package:flutter/material.dart';

/// A styled dark-theme [TextField] wrapper for the bill-splitter app.
///
/// Supports RTL / Arabic text out of the box, rounded borders,
/// filled dark background, and optional validation.
class CustomTextField extends StatelessWidget {
  const CustomTextField({
    super.key,
    required this.label,
    required this.controller,
    this.keyboardType,
    this.onSubmitted,
    this.prefixIcon,
    this.suffix,
    this.validator,
    this.autofocus = false,
    this.textDirection,
  });

  /// Hint / label text shown inside the field.
  final String label;

  /// Controller that manages the text being edited.
  final TextEditingController controller;

  /// The type of keyboard to use for editing the text.
  final TextInputType? keyboardType;

  /// Called when the user indicates that they are done editing the text.
  final ValueChanged<String>? onSubmitted;

  /// An icon that appears before the editable part of the text field.
  final IconData? prefixIcon;

  /// A widget that appears after the editable part of the text field.
  final Widget? suffix;

  /// An optional validator for [TextFormField] usage.
  final String? Function(String?)? validator;

  /// Whether this text field should focus itself if nothing else is focused.
  final bool autofocus;

  /// Explicit text direction override (defaults to RTL-aware via Directionality).
  final TextDirection? textDirection;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: colorScheme.outline.withOpacity(0.3)),
    );

    final focusedBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: colorScheme.primary, width: 2),
    );

    final errorBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: colorScheme.error, width: 2),
    );

    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      onFieldSubmitted: onSubmitted,
      validator: validator,
      autofocus: autofocus,
      textDirection: textDirection,
      style: TextStyle(color: colorScheme.onSurface, fontSize: 16),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: colorScheme.onSurface.withOpacity(0.6)),
        filled: true,
        fillColor: colorScheme.surface,
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, color: colorScheme.primary)
            : null,
        suffix: suffix,
        border: border,
        enabledBorder: border,
        focusedBorder: focusedBorder,
        errorBorder: errorBorder,
        focusedErrorBorder: errorBorder,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
    );
  }
}
