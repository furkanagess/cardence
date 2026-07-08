import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

/// Konum adımındaki metin giriş satırı (mekan adı vb.).
class LocationPickerTextFieldRow extends StatelessWidget {
  const LocationPickerTextFieldRow({
    super.key,
    required this.label,
    required this.leadingIcon,
    required this.controller,
    this.hintText,
    this.showOptionalBadge = false,
    this.optionalBadgeLabel,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.onChanged,
  });

  final String label;
  final IconData leadingIcon;
  final TextEditingController controller;
  final String? hintText;
  final bool showOptionalBadge;
  final String? optionalBadgeLabel;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final borderColor = isDark
        ? AppColors.outlineDark.withValues(alpha: 0.35)
        : AppColors.outlineVariant.withValues(alpha: 0.85);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Text(
              label,
              style: textTheme.labelMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (showOptionalBadge) ...[
              const Spacer(),
              Text(
                optionalBadgeLabel ?? '',
                style: textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.75),
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        Material(
          color: colorScheme.surface,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(color: borderColor),
          ),
          clipBehavior: Clip.antiAlias,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            child: Row(
              children: [
                Icon(
                  leadingIcon,
                  size: 20,
                  color: colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: controller,
                    textCapitalization: textCapitalization,
                    textInputAction: textInputAction,
                    style: textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                    decoration: InputDecoration(
                      hintText: hintText,
                      filled: true,
                      fillColor: colorScheme.surface,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      focusedErrorBorder: InputBorder.none,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(vertical: 10),
                      hintStyle: textTheme.bodyLarge?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    onChanged: onChanged,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
