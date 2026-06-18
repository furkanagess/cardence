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
    return Row(
      children: [
        Expanded(
          child: _ThemeOptionCard(
            label: 'Açık',
            icon: Icons.wb_sunny_outlined,
            selected: current == ThemePreference.light,
            onTap: () => onChanged(ThemePreference.light),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _ThemeOptionCard(
            label: 'Koyu',
            icon: Icons.dark_mode_outlined,
            selected: current == ThemePreference.dark,
            onTap: () => onChanged(ThemePreference.dark),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _ThemeOptionCard(
            label: 'Sistem',
            icon: Icons.desktop_windows_outlined,
            selected: current == ThemePreference.system,
            onTap: () => onChanged(ThemePreference.system),
          ),
        ),
      ],
    );
  }
}

class _ThemeOptionCard extends StatelessWidget {
  const _ThemeOptionCard({
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

    return Material(
      color: colorScheme.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: selected
                      ? AppColors.primary
                      : (isDark
                          ? AppColors.outlineDark
                          : AppColors.outlineVariant),
                  width: selected ? 2 : 1,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    icon,
                    color: selected
                        ? AppColors.primary
                        : colorScheme.onSurfaceVariant,
                    size: 26,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    label,
                    style: textTheme.labelLarge?.copyWith(
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                      color: selected
                          ? AppColors.primary
                          : colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            if (selected)
              Positioned(
                top: -6,
                right: -6,
                child: Container(
                  width: 22,
                  height: 22,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    size: 14,
                    color: AppColors.textOnPrimary,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
