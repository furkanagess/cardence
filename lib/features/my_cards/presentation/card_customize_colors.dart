import 'dart:math';

import 'package:flutter/material.dart';

import '../../../core/widgets/molecules/card_color_picker_sheet.dart';

/// Kart özelleştirme paletleri (hex).
const List<String> cardBackgroundColorOptions = [
  '#0F5C6E',
  '#1F6B4F',
  '#0D6E6E',
  '#6B2D3C',
  '#5C4033',
  '#4A3066',
  '#1C1C1C',
];

const List<String> cardTextColorOptions = [
  '#FFFFFF',
  '#6CC5DB',
  '#F5D547',
  '#E8A0BF',
  '#7FD4C1',
];

bool isPresetCardTextColor(String? hex) {
  if (hex == null) return false;
  final normalized = hex.toUpperCase();
  return cardTextColorOptions
      .any((option) => option.toUpperCase() == normalized);
}

bool isPresetCardBackgroundColor(String? hex) {
  if (hex == null) return false;
  final normalized = hex.toUpperCase();
  return cardBackgroundColorOptions
      .any((option) => option.toUpperCase() == normalized);
}

/// Kart arka planı için koyu tonlu rastgele hex üretir.
String randomCardBackgroundColorHex([Random? random]) {
  final rng = random ?? Random();
  final color = HSVColor.fromAHSV(
    1,
    rng.nextDouble() * 360,
    0.45 + rng.nextDouble() * 0.5,
    0.32 + rng.nextDouble() * 0.38,
  ).toColor();
  return CardColorPickerSheet.colorToHex(color).toUpperCase();
}

/// Metin rengi için canlı, rastgele bir hex üretir.
String randomCardAccentColorHex([Random? random]) {
  final rng = random ?? Random();
  final color = HSVColor.fromAHSV(
    1,
    rng.nextDouble() * 360,
    0.55 + rng.nextDouble() * 0.45,
    0.65 + rng.nextDouble() * 0.35,
  ).toColor();
  return CardColorPickerSheet.colorToHex(color).toUpperCase();
}
