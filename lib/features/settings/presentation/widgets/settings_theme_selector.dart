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
            icon: Icons.nights_stay_outlined,
            selected: current == ThemePreference.dark,
            onTap: () => onChanged(ThemePreference.dark),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _ThemeOptionCard(
            label: 'Sistem',
            icon: Icons.phone_iphone_rounded,
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

    return Material(
      color: selected
          ? colorScheme.primaryContainer.withValues(alpha: 0.75)
          : colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected
                  ? AppColors.primary
                  : colorScheme.outline.withValues(alpha: 0.3),
              width: selected ? 2 : 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: selected ? AppColors.primary : colorScheme.onSurfaceVariant,
                size: 24,
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: textTheme.labelMedium?.copyWith(
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  color: selected
                      ? colorScheme.onPrimaryContainer
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
