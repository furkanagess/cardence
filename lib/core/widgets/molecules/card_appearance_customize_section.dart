import 'package:flutter/material.dart';

import '../../domain/card_visual_effect.dart';
import '../../l10n/l10n_extensions.dart';
import '../atoms/custom_button.dart';
import 'card_color_customize_section.dart';
import 'card_effect_customize_section.dart';

typedef CardAppearancePreviewBuilder = Widget Function(
  String? backgroundColor,
  String? accentColor,
  CardVisualEffect effect,
);

/// Kart rengi, metin rengi ve efekt seçimi — altında Kaydet butonu.
class CardAppearanceCustomizeSection extends StatelessWidget {
  const CardAppearanceCustomizeSection({
    super.key,
    required this.backgroundColor,
    required this.accentColor,
    required this.cardEffect,
    this.lastUsedPaletteBackgroundColor,
    required this.onBackgroundColorChanged,
    required this.onAccentColorChanged,
    required this.onEffectChanged,
    this.onLastUsedPaletteBackgroundChanged,
    this.previewBuilder,
    this.showInlinePreview = true,
    this.showSaveButton = false,
    this.onSave,
    this.showBackgroundSection = true,
    this.showTextSection = true,
    this.showEffectSection = true,
    this.useAutomaticTextPill = false,
    this.compact = false,
    this.wrapColorChips = false,
    this.showDefaultColorChips = true,
    this.presetColorOptionLimit,
    this.singleRowColorChips = false,
    this.showPaletteButtons = true,
    this.showRandomBackgroundColorChip = false,
    this.showRandomTextColorChip = true,
    this.colorChipSize = 48,
    this.horizontalEdgeInset = 0,
  });

  final String? backgroundColor;
  final String? accentColor;
  final CardVisualEffect cardEffect;
  final String? lastUsedPaletteBackgroundColor;
  final ValueChanged<String?> onBackgroundColorChanged;
  final ValueChanged<String?> onAccentColorChanged;
  final ValueChanged<CardVisualEffect> onEffectChanged;
  final ValueChanged<String>? onLastUsedPaletteBackgroundChanged;
  final CardAppearancePreviewBuilder? previewBuilder;
  final bool showInlinePreview;
  final bool showSaveButton;
  final VoidCallback? onSave;
  final bool showBackgroundSection;
  final bool showTextSection;
  final bool showEffectSection;
  final bool useAutomaticTextPill;
  final bool compact;
  final bool wrapColorChips;
  final bool showDefaultColorChips;
  final int? presetColorOptionLimit;
  final bool singleRowColorChips;
  final bool showPaletteButtons;
  final bool showRandomBackgroundColorChip;
  final bool showRandomTextColorChip;
  final double colorChipSize;
  final double horizontalEdgeInset;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (showInlinePreview && previewBuilder != null) ...[
          previewBuilder!(backgroundColor, accentColor, cardEffect),
          SizedBox(height: compact ? 12 : 20),
        ],
        CardColorCustomizeSection(
          backgroundColor: backgroundColor,
          accentColor: accentColor,
          lastUsedPaletteBackgroundColor: lastUsedPaletteBackgroundColor,
          onBackgroundColorChanged: onBackgroundColorChanged,
          onAccentColorChanged: onAccentColorChanged,
          onLastUsedPaletteBackgroundChanged: onLastUsedPaletteBackgroundChanged,
          showBackgroundSection: showBackgroundSection,
          showTextSection: showTextSection,
          useAutomaticTextPill: useAutomaticTextPill,
          compact: compact,
          wrapChips: wrapColorChips,
          showDefaultColorChips: showDefaultColorChips,
          presetColorOptionLimit: presetColorOptionLimit,
          singleRowColorChips: singleRowColorChips,
          showPaletteButtons: showPaletteButtons,
          showRandomBackgroundColorChip: showRandomBackgroundColorChip,
          showRandomTextColorChip: showRandomTextColorChip,
          chipSize: colorChipSize,
          previewBuilder: previewBuilder == null
              ? null
              : (bg, accent) => previewBuilder!(bg, accent, cardEffect),
        ),
        if (showEffectSection) ...[
          SizedBox(height: compact ? 12 : 20),
          CardEffectCustomizeSection(
            selectedEffect: cardEffect,
            onEffectChanged: onEffectChanged,
            compact: compact,
            horizontalEdgeInset: horizontalEdgeInset,
          ),
        ],
        if (showSaveButton && onSave != null) ...[
          const SizedBox(height: 24),
          CustomButton(
            label: context.l10n.kaydet,
            onPressed: onSave,
          ),
        ],
      ],
    );
  }
}
