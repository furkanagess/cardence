import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/theme_preference.dart';

class SettingsThemeSelector extends StatelessWidget {
  const SettingsThemeSelector({
    super.key,
    required this.current,
    required this.onChanged,
  });

  final ThemePreference current;
  final ValueChanged<ThemePreference> onChanged;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest.withValues(
          alpha: isDark ? 0.55 : 0.85,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? AppColors.outlineDark.withValues(alpha: 0.35)
              : AppColors.outlineVariant.withValues(alpha: 0.65),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Row(
          children: [
            Expanded(
              child: _ThemeOptionChip(
                label: 'Açık',
                icon: Icons.wb_sunny_outlined,
                selected: current == ThemePreference.light,
                onTap: () => onChanged(ThemePreference.light),
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: _ThemeOptionChip(
                label: 'Koyu',
                icon: Icons.dark_mode_outlined,
                selected: current == ThemePreference.dark,
                onTap: () => onChanged(ThemePreference.dark),
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: _ThemeOptionChip(
                label: 'Sistem',
                icon: Icons.smartphone_outlined,
                selected: current == ThemePreference.system,
                onTap: () => onChanged(ThemePreference.system),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ThemeOptionChip extends StatelessWidget {
  const _ThemeOptionChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final selectedFill = isDark
        ? AppColors.primaryDarkTheme.withValues(alpha: 0.22)
        : AppColors.primaryContainer.withValues(alpha: 0.75);
    final selectedForeground =
        isDark ? AppColors.primaryDarkTheme : AppColors.primary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
          decoration: BoxDecoration(
            color: selected ? selectedFill : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 22,
                color: selected
                    ? selectedForeground
                    : colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: textTheme.labelLarge?.copyWith(
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                  letterSpacing: -0.1,
                  color: selected
                      ? selectedForeground
                      : colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
