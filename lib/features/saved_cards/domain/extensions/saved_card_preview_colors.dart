import 'package:flutter/material.dart';

import '../entities/saved_card.dart';

extension SavedCardPreviewColors on SavedCard {
  Color? get previewAccentColor => parseSavedCardHexColor(accentColor);

  Color? get previewBackgroundColor => parseSavedCardHexColor(backgroundColor);
}

Color? parseSavedCardHexColor(String? hex) {
  if (hex == null || hex.length != 7 || !hex.startsWith('#')) return null;
  return Color(int.parse(hex.substring(1), radix: 16) + 0xFF000000);
}
