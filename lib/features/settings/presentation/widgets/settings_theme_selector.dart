import 'package:flutter/material.dart';
import '../../../../core/l10n/l10n_extensions.dart';

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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textTheme = Theme.of(context).textTheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.primaryContainer.withValues(alpha: isDark ? 0.28 : 0.42),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Row(
          children: [
            _Segment(
              label: context.l10n.sistem,
              selected: current == ThemePreference.system,
              onTap: () => onChanged(ThemePreference.system),
              textTheme: textTheme,
              isDark: isDark,
            ),
            _Segment(
              label: context.l10n.ak,
              selected: current == ThemePreference.light,
              onTap: () => onChanged(ThemePreference.light),
              textTheme: textTheme,
              isDark: isDark,
            ),
            _Segment(
              label: context.l10n.koyu,
              selected: current == ThemePreference.dark,
              onTap: () => onChanged(ThemePreference.dark),
              textTheme: textTheme,
              isDark: isDark,
            ),
          ],
        ),
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.textTheme,
    required this.isDark,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final TextTheme textTheme;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: selected
                  ? (isDark ? AppColors.surfaceDark : AppColors.surfaceLight)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
              boxShadow: selected && !isDark
                  ? [
                      BoxShadow(
                        color: AppColors.textPrimary.withValues(alpha: 0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            alignment: Alignment.center,
            child: Text(
              label,
              style: textTheme.labelLarge?.copyWith(
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: selected
                    ? (isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimary)
                    : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
