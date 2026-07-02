import 'package:flutter/material.dart';

import '../../../../core/l10n/l10n_extensions.dart';
import '../../../../core/theme/app_accent_palette.dart';
import '../../../../core/theme/app_colors.dart';

/// Giriş ekranında uygulama vurgu rengi seçimi.
class LoginAccentColorPicker extends StatelessWidget {
  const LoginAccentColorPicker({
    super.key,
    required this.selectedId,
    required this.onSelected,
  });

  final String selectedId;
  final ValueChanged<String> onSelected;

  static const double _swatchSize = 30;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          context.l10n.uygulamaRengi,
          textAlign: TextAlign.center,
          style: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 10,
          runSpacing: 10,
          children: [
            for (final option in AppAccentPalette.options)
              _AccentSwatch(
                option: option,
                isSelected: option.id == selectedId,
                isDark: isDark,
                onTap: () => onSelected(option.id),
              ),
          ],
        ),
      ],
    );
  }
}

class _AccentSwatch extends StatelessWidget {
  const _AccentSwatch({
    required this.option,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
  });

  final AppAccentOption option;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ringColor = isSelected
        ? option.primary
        : (isDark ? AppColors.outlineDark : AppColors.outlineVariant);

    return Semantics(
      button: true,
      selected: isSelected,
      label: option.id,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: LoginAccentColorPicker._swatchSize,
          height: LoginAccentColorPicker._swatchSize,
          decoration: BoxDecoration(
            color: option.primary,
            shape: BoxShape.circle,
            border: Border.all(
              color: ringColor,
              width: isSelected ? 2.5 : 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: option.primary.withValues(alpha: 0.28),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: isSelected
              ? const Icon(
                  Icons.check_rounded,
                  size: 16,
                  color: AppColors.textOnPrimary,
                )
              : null,
        ),
      ),
    );
  }
}
