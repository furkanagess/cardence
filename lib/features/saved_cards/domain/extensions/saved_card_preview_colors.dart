import 'package:flutter/material.dart';

import '../entities/saved_card.dart';

extension SavedCardPreviewColors on SavedCard {
  Color? get previewAccentColor => parseSavedCardHexColor(accentColor);

  Color? get previewBackgroundColor => parseSavedCardHexColor(backgroundColor);
}

Color? parseSavedCardHexColor(String? hex) {
  if (hex == null || hex.trim().isEmpty) return null;

  var value = hex.trim();
  if (value.startsWith('#')) value = value.substring(1);
  if (value.length == 6) value = 'FF$value';
  if (value.length != 8) return null;

  final parsed = int.tryParse(value, radix: 16);
  if (parsed == null) return null;
  return Color(parsed);
}
