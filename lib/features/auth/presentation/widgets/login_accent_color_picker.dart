import 'package:flutter/material.dart';

import '../../../../core/l10n/l10n_extensions.dart';
import '../../../../core/theme/app_accent_palette.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/molecules/card_color_picker_sheet.dart';

/// Giriş ekranında uygulama vurgu rengi seçimi (+ özel palette).
class LoginAccentColorPicker extends StatelessWidget {
  const LoginAccentColorPicker({
    super.key,
    required this.selectedId,
    required this.onSelected,
  });

  final String selectedId;
  final ValueChanged<String> onSelected;

  static const double _swatchSize = 30;

  Future<void> _openCustomPalette(BuildContext context) async {
    final initial = AppAccentPalette.isCustomId(selectedId)
        ? AppAccentPalette.selected.primary
        : AppAccentPalette.byId(selectedId).primary;

    final color = await CardColorPickerSheet.show(
      context,
      title: context.l10n.uygulamaRengi,
      initialColor: initial,
      editingBackground: false,
    );
    if (color == null || !context.mounted) return;
    onSelected(AppAccentPalette.customIdFromColor(color));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isCustomSelected = AppAccentPalette.isCustomId(selectedId);
    final customColor = isCustomSelected
        ? AppAccentPalette.colorFromCustomId(selectedId)
        : null;

    return SizedBox(
      height: _swatchSize + 4,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: constraints.maxWidth),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var i = 0;
                      i < AppAccentPalette.options.length;
                      i++) ...[
                    if (i > 0) const SizedBox(width: 10),
                    _AccentSwatch(
                      color: AppAccentPalette.options[i].primary,
                      isSelected: !isCustomSelected &&
                          AppAccentPalette.options[i].id == selectedId,
                      isDark: isDark,
                      onTap: () =>
                          onSelected(AppAccentPalette.options[i].id),
                    ),
                  ],
                  const SizedBox(width: 10),
                  _PaletteSwatch(
                    isSelected: isCustomSelected,
                    selectedColor: customColor,
                    isDark: isDark,
                    onTap: () => _openCustomPalette(context),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _AccentSwatch extends StatelessWidget {
  const _AccentSwatch({
    required this.color,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
  });

  final Color color;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ringColor = isSelected
        ? color
        : (isDark ? AppColors.outlineDark : AppColors.outlineVariant);

    return Semantics(
      button: true,
      selected: isSelected,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: LoginAccentColorPicker._swatchSize,
          height: LoginAccentColorPicker._swatchSize,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(
              color: ringColor,
              width: isSelected ? 2.5 : 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: color.withValues(alpha: 0.28),
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

/// Hazır renklerin yanındaki palette butonu — özel renk seçimi.
class _PaletteSwatch extends StatelessWidget {
  const _PaletteSwatch({
    required this.isSelected,
    required this.isDark,
    required this.onTap,
    this.selectedColor,
  });

  final bool isSelected;
  final Color? selectedColor;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ringColor = isSelected
        ? (selectedColor ?? AppColors.primary)
        : (isDark ? AppColors.outlineDark : AppColors.outlineVariant);

    return Semantics(
      button: true,
      selected: isSelected,
      label: context.l10n.uygulamaRengi,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: LoginAccentColorPicker._swatchSize,
          height: LoginAccentColorPicker._swatchSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: selectedColor == null
                ? const SweepGradient(
                    colors: [
                      Color(0xFFE53935),
                      Color(0xFFFB8C00),
                      Color(0xFFFDD835),
                      Color(0xFF43A047),
                      Color(0xFF1E88E5),
                      Color(0xFF8E24AA),
                      Color(0xFFE53935),
                    ],
                  )
                : null,
            color: selectedColor,
            border: Border.all(
              color: ringColor,
              width: isSelected ? 2.5 : 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: (selectedColor ?? AppColors.primary)
                          .withValues(alpha: 0.28),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Icon(
            Icons.palette_rounded,
            size: 16,
            color: selectedColor == null
                ? AppColors.textOnPrimary
                : (selectedColor!.computeLuminance() > 0.55
                    ? AppColors.textPrimary
                    : AppColors.textOnPrimary),
          ),
        ),
      ),
    );
  }
}
