import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

/// Konum seçim satırı (ülke, il·ilçe vb.).
class LocationPickerFieldRow extends StatelessWidget {
  const LocationPickerFieldRow({
    super.key,
    required this.label,
    required this.leadingIcon,
    this.leadingIconColor,
    this.trailingIcon,
    this.value,
    this.placeholder,
    this.trailing,
    this.onTap,
    this.enabled = true,
    this.showOptionalBadge = false,
    this.optionalBadgeLabel,
    this.child,
  });

  final String label;
  final IconData leadingIcon;
  final Color? leadingIconColor;
  final IconData? trailingIcon;
  final String? value;
  final String? placeholder;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool enabled;
  final bool showOptionalBadge;
  final String? optionalBadgeLabel;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final hasValue = value != null && value!.trim().isNotEmpty;
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
          child: child ??
              InkWell(
                onTap: enabled ? onTap : null,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  child: Row(
                    children: [
                      Icon(
                        leadingIcon,
                        size: 20,
                        color: leadingIconColor ??
                            (enabled
                                ? colorScheme.onSurfaceVariant
                                : colorScheme.onSurface
                                    .withValues(alpha: 0.38)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          hasValue ? value!.trim() : (placeholder ?? ''),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.bodyLarge?.copyWith(
                            color: hasValue
                                ? colorScheme.onSurface
                                : colorScheme.onSurfaceVariant,
                            fontWeight:
                                hasValue ? FontWeight.w600 : FontWeight.w500,
                          ),
                        ),
                      ),
                      if (trailing != null)
                        trailing!
                      else if (trailingIcon != null)
                        Icon(
                          trailingIcon,
                          size: 20,
                          color: enabled
                              ? colorScheme.onSurfaceVariant
                              : colorScheme.onSurface.withValues(alpha: 0.38),
                        ),
                    ],
                  ),
                ),
              ),
        ),
      ],
    );
  }
}
