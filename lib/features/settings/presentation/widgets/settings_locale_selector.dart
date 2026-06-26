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
              child: _LocaleOptionChip(
                label: context.l10n.turkce,
                flag: '🇹🇷',
                selected: current == LocalePreference.turkish,
                onTap: () => onChanged(LocalePreference.turkish),
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: _LocaleOptionChip(
                label: context.l10n.ingilizce,
                flag: '🇬🇧',
                selected: current == LocalePreference.english,
                onTap: () => onChanged(LocalePreference.english),
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: _LocaleOptionChip(
                label: context.l10n.sistem,
                icon: Icons.smartphone_outlined,
                selected: current == LocalePreference.system,
                onTap: () => onChanged(LocalePreference.system),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LocaleOptionChip extends StatelessWidget {
  const _LocaleOptionChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.flag,
    this.icon,
  }) : assert(flag != null || icon != null, 'flag veya icon verilmeli');

  final String label;
  final String? flag;
  final IconData? icon;
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
    final unselectedForeground = colorScheme.onSurfaceVariant;

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
              _LocaleOptionGlyph(
                flag: flag,
                icon: icon,
                selected: selected,
                selectedForeground: selectedForeground,
                unselectedForeground: unselectedForeground,
              ),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
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

class _LocaleOptionGlyph extends StatelessWidget {
  const _LocaleOptionGlyph({
    required this.selected,
    required this.selectedForeground,
    required this.unselectedForeground,
    this.flag,
    this.icon,
  });

  final String? flag;
  final IconData? icon;
  final bool selected;
  final Color selectedForeground;
  final Color unselectedForeground;

  @override
  Widget build(BuildContext context) {
    if (flag != null) {
      return SizedBox(
        width: 30,
        height: 30,
        child: Center(
          child: Text(
            flag!,
            style: const TextStyle(fontSize: 22, height: 1),
          ),
        ),
      );
    }

    return SizedBox(
      width: 30,
      height: 30,
      child: Icon(
        icon,
        size: 22,
        color: selected ? selectedForeground : unselectedForeground,
      ),
    );
  }
}
