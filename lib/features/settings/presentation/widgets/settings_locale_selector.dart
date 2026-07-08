import 'package:flutter/material.dart';

import '../../../../core/l10n/l10n_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/locale_preference.dart';

class SettingsLocaleSelector extends StatelessWidget {
  const SettingsLocaleSelector({
    super.key,
    required this.current,
    required this.onChanged,
  });

  final LocalePreference current;
  final ValueChanged<LocalePreference> onChanged;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          context.l10n.uygulamaDili,
          style: textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        DecoratedBox(
          decoration: BoxDecoration(
            color:
                AppColors.primaryContainer.withValues(alpha: isDark ? 0.28 : 0.42),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: Row(
              children: [
                _LocaleSegment(
                  label: context.l10n.turkce,
                  flag: '🇹🇷',
                  selected: current == LocalePreference.turkish,
                  onTap: () => onChanged(LocalePreference.turkish),
                  textTheme: textTheme,
                  isDark: isDark,
                ),
                _LocaleSegment(
                  label: context.l10n.ingilizce,
                  flag: '🇬🇧',
                  selected: current == LocalePreference.english,
                  onTap: () => onChanged(LocalePreference.english),
                  textTheme: textTheme,
                  isDark: isDark,
                ),
                _LocaleSegment(
                  label: context.l10n.sistem,
                  icon: Icons.smartphone_outlined,
                  selected: current == LocalePreference.system,
                  onTap: () => onChanged(LocalePreference.system),
                  textTheme: textTheme,
                  isDark: isDark,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _LocaleSegment extends StatelessWidget {
  const _LocaleSegment({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.textTheme,
    required this.isDark,
    this.flag,
    this.icon,
  }) : assert(flag != null || icon != null, 'flag veya icon verilmeli');

  final String label;
  final String? flag;
  final IconData? icon;
  final bool selected;
  final VoidCallback onTap;
  final TextTheme textTheme;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final unselectedColor = Theme.of(context).colorScheme.onSurfaceVariant;

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (flag != null)
                  Text(
                    flag!,
                    style: const TextStyle(fontSize: 20, height: 1.1),
                  )
                else
                  Icon(
                    icon,
                    size: 20,
                    color: selected
                        ? (isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimary)
                        : unselectedColor,
                  ),
                const SizedBox(height: 6),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.labelMedium?.copyWith(
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    color: selected
                        ? (isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimary)
                        : unselectedColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
