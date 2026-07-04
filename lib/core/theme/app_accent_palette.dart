import 'package:flutter/material.dart';

/// Uygulama vurgu rengi seçenekleri (giriş ekranı + tüm uygulama).
class AppAccentOption {
  const AppAccentOption({
    required this.id,
    required this.primary,
    required this.primaryDark,
    required this.primaryLight,
    required this.primaryContainer,
    required this.onPrimaryContainer,
    required this.primaryContainerDark,
    required this.onPrimaryContainerDark,
    required this.primaryDarkTheme,
  });

  final String id;
  final Color primary;
  final Color primaryDark;
  final Color primaryLight;
  final Color primaryContainer;
  final Color onPrimaryContainer;
  final Color primaryContainerDark;
  final Color onPrimaryContainerDark;
  final Color primaryDarkTheme;

  static AppAccentOption fromSeed({
    required String id,
    required Color primary,
    required Color primaryDark,
    required Color primaryLight,
  }) {
    return AppAccentOption(
      id: id,
      primary: primary,
      primaryDark: primaryDark,
      primaryLight: primaryLight,
      primaryContainer: Color.alphaBlend(
        primary.withValues(alpha: 0.14),
        Colors.white,
      ),
      onPrimaryContainer: primaryDark,
      primaryContainerDark: Color.alphaBlend(
        primary.withValues(alpha: 0.32),
        const Color(0xFF1A2028),
      ),
      onPrimaryContainerDark: Color.alphaBlend(
        primary.withValues(alpha: 0.14),
        Colors.white,
      ),
      primaryDarkTheme: Color.lerp(primary, Colors.white, 0.58)!,
    );
  }

  /// Kullanıcının seçtiği tek renkten tam vurgu paleti üretir.
  static AppAccentOption fromPrimaryColor(Color primary) {
    return fromSeed(
      id: AppAccentPalette.customIdFromColor(primary),
      primary: primary,
      primaryDark: Color.lerp(primary, Colors.black, 0.28)!,
      primaryLight: Color.lerp(primary, Colors.white, 0.18)!,
    );
  }
}

/// Seçilebilir vurgu renkleri ve aktif seçim.
class AppAccentPalette {
  AppAccentPalette._();

  static const String defaultId = 'petrol_sapphire';
  static const String customIdPrefix = 'custom_';

  static final List<AppAccentOption> options = [
    AppAccentOption.fromSeed(
      id: 'petrol_sapphire',
      primary: Color(0xFF0F5C6E),
      primaryDark: Color(0xFF083D49),
      primaryLight: Color(0xFF1A7A91),
    ),
    AppAccentOption.fromSeed(
      id: 'classic_navy',
      primary: Color(0xFF1B365D),
      primaryDark: Color(0xFF122640),
      primaryLight: Color(0xFF2E4A73),
    ),
    AppAccentOption.fromSeed(
      id: 'forest_green',
      primary: Color(0xFF1F6B4F),
      primaryDark: Color(0xFF134A38),
      primaryLight: Color(0xFF2D8A68),
    ),
    AppAccentOption.fromSeed(
      id: 'royal_indigo',
      primary: Color(0xFF3D4EAB),
      primaryDark: Color(0xFF2A3578),
      primaryLight: Color(0xFF5568C4),
    ),
  ];

  static AppAccentOption _selected = options.first;

  static AppAccentOption get selected => _selected;

  static bool isCustomId(String id) => id.startsWith(customIdPrefix);

  static String customIdFromColor(Color color) {
    final r = (color.r * 255).round().clamp(0, 255);
    final g = (color.g * 255).round().clamp(0, 255);
    final b = (color.b * 255).round().clamp(0, 255);
    final hex =
        '${r.toRadixString(16).padLeft(2, '0')}${g.toRadixString(16).padLeft(2, '0')}${b.toRadixString(16).padLeft(2, '0')}';
    return '$customIdPrefix$hex';
  }

  static Color? colorFromCustomId(String id) {
    if (!isCustomId(id)) return null;
    final hex = id.substring(customIdPrefix.length).trim();
    if (hex.length != 6) return null;
    final value = int.tryParse(hex, radix: 16);
    if (value == null) return null;
    return Color(0xFF000000 | value);
  }

  /// Geçerli bir accent id döndürür; bilinmeyen değerlerde varsayılana düşer.
  static String normalizeId(String? id) {
    if (id == null || id.isEmpty) return defaultId;
    if (isCustomId(id)) {
      return colorFromCustomId(id) != null ? id.toLowerCase() : defaultId;
    }
    for (final option in options) {
      if (option.id == id) return id;
    }
    return defaultId;
  }

  static void selectById(String id) {
    _selected = byId(id);
  }

  static void selectCustomColor(Color color) {
    _selected = AppAccentOption.fromPrimaryColor(color);
  }

  static void init(String? storedId) {
    selectById(storedId ?? defaultId);
  }

  static AppAccentOption byId(String id) {
    final normalized = normalizeId(id);
    if (isCustomId(normalized)) {
      final color = colorFromCustomId(normalized)!;
      return AppAccentOption.fromPrimaryColor(color);
    }
    return options.firstWhere(
      (option) => option.id == normalized,
      orElse: () => options.first,
    );
  }
}
