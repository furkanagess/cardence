import 'package:flutter/material.dart';
import '../../../core/l10n/l10n_extensions.dart';

import '../../theme/app_colors.dart';
import '../../../features/my_cards/presentation/card_customize_colors.dart';
import '../../../features/my_cards/presentation/widgets/my_card_preview_helpers.dart';
import 'card_color_picker_sheet.dart';

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
    this.previewBuilder,
    this.compact = false,
    this.wrapChips = false,
    this.showDefaultColorChips = true,
    this.presetColorOptionLimit,
    this.singleRowColorChips = false,
    this.showPaletteButtons = true,
    this.showRandomBackgroundColorChip = false,
    this.showRandomTextColorChip = true,
    this.chipSize = 48,
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
  final CardColorPickerPreviewBuilder? previewBuilder;
  final bool compact;
  final bool wrapChips;
  final bool showDefaultColorChips;
  final int? presetColorOptionLimit;
  final bool singleRowColorChips;
  final bool showPaletteButtons;
  final bool showRandomBackgroundColorChip;
  final bool showRandomTextColorChip;
  final double chipSize;

  List<String> get _backgroundPresets {
    final options = cardBackgroundColorOptions;
    if (presetColorOptionLimit == null) return options;
    return options.take(presetColorOptionLimit!).toList(growable: false);
  }

  List<String> get _textPresets {
    final options = cardTextColorOptions;
    if (presetColorOptionLimit == null) return options;
    return options.take(presetColorOptionLimit!).toList(growable: false);
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
    final pickerColor = currentBg ?? lastUsed ?? AppColors.surfaceLight;

    final applied = await CardColorPickerSheet.show(
      context,
      title: context.l10n.zelKartRengi,
      initialColor: pickerColor,
      editingBackground: true,
      previewBackgroundColor: backgroundColor,
      previewAccentColor: accentColor,
      previewBuilder: previewBuilder,
    );
    if (applied == null) return;

    _applyCustomBackgroundColor(CardColorPickerSheet.colorToHex(applied));
  }

  void _applyCustomBackgroundColor(String hex) {
    final onLastUsed = onLastUsedPaletteBackgroundChanged;
    if (onLastUsed != null) {
      onLastUsed(hex);
    } else {
      onBackgroundColorChanged(hex);
    }
  }

  Future<void> _openTextPalette(BuildContext context) async {
    final current = MyCardPreviewHelpers.parseHexColor(accentColor);
    final bg = MyCardPreviewHelpers.parseHexColor(backgroundColor);
    final pickerColor = current ??
        (bg != null
            ? (bg.computeLuminance() > 0.5
                ? AppColors.textPrimary
                : AppColors.surfaceLight)
            : AppColors.textPrimary);

    final applied = await CardColorPickerSheet.show(
      context,
      title: context.l10n.zelMetinRengi,
      initialColor: pickerColor,
      editingBackground: false,
      previewBackgroundColor: backgroundColor,
      previewAccentColor: accentColor,
      previewBuilder: previewBuilder,
    );
    if (applied == null) return;

    onAccentColorChanged(CardColorPickerSheet.colorToHex(applied));
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
          _ChipRow(
            compact: compact,
            wrapChips: wrapChips,
            singleRow: singleRowColorChips,
            children: [
              if (showDefaultColorChips)
                _BackgroundChip(
                  hex: null,
                  size: chipSize,
                  selected: backgroundColor == null,
                  onTap: () => onBackgroundColorChanged(null),
                ),
              ..._backgroundPresets.map(
                (hex) => _BackgroundChip(
                  hex: hex,
                  size: chipSize,
                  selected: backgroundColor == hex,
                  onTap: () => onBackgroundColorChanged(hex),
                ),
              ),
              if (_hasLastUsed && !singleRowColorChips)
                _BackgroundChip(
                  hex: lastUsedPaletteBackgroundColor,
                  size: chipSize,
                  selected: backgroundColor == lastUsedPaletteBackgroundColor,
                  onTap: () =>
                      onBackgroundColorChanged(lastUsedPaletteBackgroundColor),
                ),
              if (showRandomBackgroundColorChip)
                _RandomColorChip(
                  colorHex: backgroundColor,
                  size: chipSize,
                  selected: backgroundColor != null &&
                      !isPresetCardBackgroundColor(backgroundColor),
                  onTap: () {
                    _applyCustomBackgroundColor(randomCardBackgroundColorHex());
                  },
                ),
              if (showPaletteButtons)
                _PaletteButton(
                  size: chipSize,
                  onTap: () => _openBackgroundPalette(context),
                ),
            ],
          ),
        ],
        if (showBackgroundSection && showTextSection)
          SizedBox(height: compact ? 12 : 20),
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
          _ChipRow(
            compact: compact,
            wrapChips: wrapChips,
            singleRow: singleRowColorChips,
            children: [
              if (showDefaultColorChips)
                _TextColorChip(
                  hex: null,
                  size: chipSize,
                  selected: accentColor == null,
                  onTap: () => onAccentColorChanged(null),
                  useAutomaticPill: useAutomaticTextPill,
                ),
              ..._textPresets.map(
                (hex) => _TextColorChip(
                  hex: hex,
                  size: chipSize,
                  selected: accentColor == hex,
                  onTap: () => onAccentColorChanged(hex),
                ),
              ),
              if (showRandomTextColorChip)
                _RandomColorChip(
                  colorHex: accentColor,
                  size: chipSize,
                  selected: accentColor != null &&
                      !isPresetCardTextColor(accentColor),
                  onTap: () => onAccentColorChanged(randomCardAccentColorHex()),
                ),
              if (showPaletteButtons)
                _PaletteButton(
                  size: chipSize,
                  onTap: () => _openTextPalette(context),
                ),
            ],
          ),
        ],
      ],
    );
  }
}

class _ChipRow extends StatelessWidget {
  const _ChipRow({
    required this.children,
    this.compact = false,
    this.wrapChips = false,
    this.singleRow = false,
  });

  final List<Widget> children;
  final bool compact;
  final bool wrapChips;
  final bool singleRow;

  @override
  Widget build(BuildContext context) {
    if (singleRow) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) const SizedBox(width: 8),
            children[i],
          ],
        ],
      );
    }

    if (!compact || wrapChips) {
      return Wrap(
        spacing: 12,
        runSpacing: 12,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: children,
      );
    }

    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: children.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) => children[index],
      ),
    );
  }
}

class _BackgroundChip extends StatelessWidget {
  const _BackgroundChip({
    required this.hex,
    required this.selected,
    required this.onTap,
    this.size = 48,
  });

  final String? hex;
  final bool selected;
  final VoidCallback onTap;
  final double size;

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
        width: size,
        height: size,
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
                size: size * 0.46,
              )
            : (selected && color != null && color.computeLuminance() > 0.5)
                ? Icon(
                    Icons.check_rounded,
                    color: AppColors.textPrimary,
                    size: size * 0.46,
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
    this.size = 48,
  });

  final String? hex;
  final bool selected;
  final VoidCallback onTap;
  final bool useAutomaticPill;
  final double size;

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
                color:
                    selected ? AppColors.primary : colorScheme.onSurfaceVariant,
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
        width: size,
        height: size,
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
                size: size * 0.46,
              )
            : Center(
                child: Text(
                  'A',
                  style: TextStyle(
                    fontSize: size * 0.42,
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

class _RandomColorChip extends StatelessWidget {
  const _RandomColorChip({
    required this.colorHex,
    required this.selected,
    required this.onTap,
    this.size = 48,
  });

  final String? colorHex;
  final bool selected;
  final VoidCallback onTap;
  final double size;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final fillColor =
        selected && colorHex != null ? MyCardPreviewHelpers.parseHexColor(colorHex) : null;

    return Semantics(
      button: true,
      label: context.l10n.rastgeleRenk,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: fillColor ?? colorScheme.surfaceContainerHighest,
            border: Border.all(
              color: selected
                  ? AppColors.primary
                  : colorScheme.outline.withValues(alpha: 0.4),
              width: selected ? 3 : 1.5,
            ),
          ),
          child: Icon(
            Icons.shuffle_rounded,
            size: size * 0.46,
            color: selected && fillColor != null
                ? (fillColor.computeLuminance() > 0.55
                    ? AppColors.textPrimary
                    : AppColors.textOnPrimary)
                : AppColors.primary,
          ),
        ),
      ),
    );
  }
}

class _PaletteButton extends StatelessWidget {
  const _PaletteButton({
    required this.onTap,
    this.size = 48,
  });

  final VoidCallback onTap;
  final double size;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Material(
      color: colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: SizedBox(
          width: size,
          height: size,
          child: Icon(
            Icons.palette_outlined,
            color: AppColors.primary,
            size: size * 0.46,
          ),
        ),
      ),
    );
  }
}
