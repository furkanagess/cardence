import 'package:flutter/material.dart';
import '../../../core/l10n/l10n_extensions.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

import '../../theme/app_colors.dart';
import '../atoms/custom_button.dart';
import '../../../features/my_cards/presentation/card_customize_colors.dart';
import '../../../features/my_cards/presentation/widgets/my_card_preview_helpers.dart';

/// Kart arka plan ve metin rengi seçimi (chip + özel palet).
class CardColorCustomizeSection extends StatelessWidget {
  const CardColorCustomizeSection({
    super.key,
    required this.backgroundColor,
    required this.accentColor,
    this.lastUsedPaletteBackgroundColor,
    required this.onBackgroundColorChanged,
    required this.onAccentColorChanged,
    this.onLastUsedPaletteBackgroundChanged,
    this.showBackgroundSection = true,
    this.showTextSection = true,
    this.useAutomaticTextPill = false,
  });

  final String? backgroundColor;
  final String? accentColor;
  final String? lastUsedPaletteBackgroundColor;
  final ValueChanged<String?> onBackgroundColorChanged;
  final ValueChanged<String?> onAccentColorChanged;
  final ValueChanged<String>? onLastUsedPaletteBackgroundChanged;
  final bool showBackgroundSection;
  final bool showTextSection;
  final bool useAutomaticTextPill;

  static String _colorToHex(Color c) {
    final r = (c.r * 255).round().clamp(0, 255);
    final g = (c.g * 255).round().clamp(0, 255);
    final b = (c.b * 255).round().clamp(0, 255);
    return '#${r.toRadixString(16).padLeft(2, '0')}${g.toRadixString(16).padLeft(2, '0')}${b.toRadixString(16).padLeft(2, '0')}';
  }

  bool get _hasLastUsed =>
      lastUsedPaletteBackgroundColor != null &&
      lastUsedPaletteBackgroundColor!.length == 7 &&
      lastUsedPaletteBackgroundColor!.startsWith('#') &&
      !cardBackgroundColorOptions.contains(lastUsedPaletteBackgroundColor);

  Future<void> _openBackgroundPalette(BuildContext context) async {
    final currentBg = MyCardPreviewHelpers.parseHexColor(backgroundColor);
    final lastUsed =
        MyCardPreviewHelpers.parseHexColor(lastUsedPaletteBackgroundColor);
    var pickerColor = currentBg ?? lastUsed ?? AppColors.surfaceLight;

    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.l10n.zelKartRengi),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: pickerColor,
            onColorChanged: (c) => pickerColor = c,
            enableAlpha: false,
            hexInputBar: true,
            labelTypes: const [],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(context.l10n.iptal),
          ),
          CustomButton(
            label: context.l10n.uygula,
            onPressed: () {
              final hex = _colorToHex(pickerColor);
              Navigator.of(ctx).pop();
              onBackgroundColorChanged(hex);
              onLastUsedPaletteBackgroundChanged?.call(hex);
            },
            fullWidth: false,
          ),
        ],
      ),
    );
  }

  Future<void> _openTextPalette(BuildContext context) async {
    final current = MyCardPreviewHelpers.parseHexColor(accentColor);
    final bg = MyCardPreviewHelpers.parseHexColor(backgroundColor);
    var pickerColor = current ??
        (bg != null
            ? (bg.computeLuminance() > 0.5
                ? AppColors.textPrimary
                : AppColors.surfaceLight)
            : AppColors.textPrimary);

    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.l10n.zelMetinRengi),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: pickerColor,
            onColorChanged: (c) => pickerColor = c,
            enableAlpha: false,
            hexInputBar: true,
            labelTypes: const [],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(context.l10n.iptal),
          ),
          CustomButton(
            label: context.l10n.uygula,
            onPressed: () {
              Navigator.of(ctx).pop();
              onAccentColorChanged(_colorToHex(pickerColor));
            },
            fullWidth: false,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (showBackgroundSection) ...[
          if (!useAutomaticTextPill)
            Text(
              context.l10n.kartRengi,
              style: textTheme.labelMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
              ),
            ),
          if (!useAutomaticTextPill) const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _BackgroundChip(
                hex: null,
                selected: backgroundColor == null,
                onTap: () => onBackgroundColorChanged(null),
              ),
              ...cardBackgroundColorOptions.map(
                (hex) => _BackgroundChip(
                  hex: hex,
                  selected: backgroundColor == hex,
                  onTap: () => onBackgroundColorChanged(hex),
                ),
              ),
              if (_hasLastUsed)
                _BackgroundChip(
                  hex: lastUsedPaletteBackgroundColor,
                  selected:
                      backgroundColor == lastUsedPaletteBackgroundColor,
                  onTap: () =>
                      onBackgroundColorChanged(lastUsedPaletteBackgroundColor),
                ),
              _PaletteButton(onTap: () => _openBackgroundPalette(context)),
            ],
          ),
        ],
        if (showBackgroundSection && showTextSection) const SizedBox(height: 20),
        if (showTextSection) ...[
          if (!useAutomaticTextPill)
            Text(
              context.l10n.metinRengi,
              style: textTheme.labelMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
              ),
            ),
          if (!useAutomaticTextPill) const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              _TextColorChip(
                hex: null,
                selected: accentColor == null,
                onTap: () => onAccentColorChanged(null),
                useAutomaticPill: useAutomaticTextPill,
              ),
              ...cardTextColorOptions.map(
                (hex) => _TextColorChip(
                  hex: hex,
                  selected: accentColor == hex,
                  onTap: () => onAccentColorChanged(hex),
                ),
              ),
              _PaletteButton(onTap: () => _openTextPalette(context)),
            ],
          ),
        ],
      ],
    );
  }
}

class _BackgroundChip extends StatelessWidget {
  const _BackgroundChip({
    required this.hex,
    required this.selected,
    required this.onTap,
  });

  final String? hex;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDefault = hex == null;
    final color = hex != null
        ? MyCardPreviewHelpers.parseHexColor(hex)
        : colorScheme.surface;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: selected
                ? AppColors.primary
                : colorScheme.outline.withValues(alpha: 0.4),
            width: selected ? 3 : 1.5,
          ),
        ),
        child: isDefault
            ? Icon(
                selected ? Icons.check_rounded : Icons.palette_outlined,
                color:
                    selected ? AppColors.primary : colorScheme.onSurfaceVariant,
                size: 22,
              )
            : (selected && color != null && color.computeLuminance() > 0.5)
                ? const Icon(
                    Icons.check_rounded,
                    color: AppColors.textPrimary,
                    size: 22,
                  )
                : null,
      ),
    );
  }
}

class _TextColorChip extends StatelessWidget {
  const _TextColorChip({
    required this.hex,
    required this.selected,
    required this.onTap,
    this.useAutomaticPill = false,
  });

  final String? hex;
  final bool selected;
  final VoidCallback onTap;
  final bool useAutomaticPill;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isDefault = hex == null;

    if (isDefault && useAutomaticPill) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(999),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: selected
                  ? colorScheme.primaryContainer
                  : colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: selected
                    ? AppColors.primary.withValues(alpha: 0.35)
                    : colorScheme.outlineVariant.withValues(alpha: 0.5),
              ),
            ),
            child: Text(
              context.l10n.otomatik,
              style: textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: selected
                    ? AppColors.primary
                    : colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
      );
    }

    final color = hex != null
        ? MyCardPreviewHelpers.parseHexColor(hex)
        : colorScheme.surfaceContainerHighest;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: selected
                ? AppColors.primary
                : colorScheme.outline.withValues(alpha: 0.4),
            width: selected ? 3 : 1.5,
          ),
        ),
        child: isDefault
            ? Icon(
                selected ? Icons.check_rounded : Icons.title_outlined,
                color:
                    selected ? AppColors.primary : colorScheme.onSurfaceVariant,
                size: 22,
              )
            : Center(
                child: Text(
                  'A',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: color != null && color.computeLuminance() > 0.5
                        ? AppColors.textPrimary
                        : AppColors.textOnPrimary,
                  ),
                ),
              ),
      ),
    );
  }
}

class _PaletteButton extends StatelessWidget {
  const _PaletteButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Material(
      color: colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: const SizedBox(
          width: 48,
          height: 48,
          child: Icon(
            Icons.palette_outlined,
            color: AppColors.primary,
            size: 22,
          ),
        ),
      ),
    );
  }
}
