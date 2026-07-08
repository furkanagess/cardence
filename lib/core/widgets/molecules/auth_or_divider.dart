import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

/// Auth ekranlarında sosyal giriş öncesi "VEYA" ayırıcı — çizgi + ortada kapsül badge.
class AuthOrDivider extends StatelessWidget {
  const AuthOrDivider({
    super.key,
    required this.label,
  });

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final lineColor =
        isDark ? AppColors.outlineDark : AppColors.outlineVariant;
    final badgeBackground =
        isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final borderColor =
        isDark ? AppColors.outlineDark : AppColors.outlineVariant;
    final textColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;

    return Row(
      children: [
        Expanded(
          child: Divider(color: lineColor, height: 1, thickness: 1),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 12),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: badgeBackground,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: borderColor),
          ),
          child: Text(
            label.toUpperCase(),
            style: theme.textTheme.labelSmall?.copyWith(
              color: textColor,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8,
            ),
          ),
        ),
        Expanded(
          child: Divider(color: lineColor, height: 1, thickness: 1),
        ),
      ],
    );
  }
}
