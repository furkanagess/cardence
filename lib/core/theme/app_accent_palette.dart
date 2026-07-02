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
}

/// Seçilebilir vurgu renkleri ve aktif seçim.
class AppAccentPalette {
  AppAccentPalette._();

  static const String defaultId = 'petrol_sapphire';

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
    AppAccentOption.fromSeed(
      id: 'deep_teal',
      primary: Color(0xFF0D6E6E),
      primaryDark: Color(0xFF084A4A),
      primaryLight: Color(0xFF1A9191),
    ),
    AppAccentOption.fromSeed(
      id: 'slate_steel',
      primary: Color(0xFF475569),
      primaryDark: Color(0xFF2F3A47),
      primaryLight: Color(0xFF64748B),
    ),
    AppAccentOption.fromSeed(
      id: 'wine_burgundy',
      primary: Color(0xFF7B2D4A),
      primaryDark: Color(0xFF551E33),
      primaryLight: Color(0xFF9A4562),
    ),
    AppAccentOption.fromSeed(
      id: 'midnight_blue',
      primary: Color(0xFF2A3F6B),
      primaryDark: Color(0xFF1A2847),
      primaryLight: Color(0xFF3F5A8F),
    ),
  ];

  static AppAccentOption _selected = options.first;

  static AppAccentOption get selected => _selected;

  static void selectById(String id) {
    _selected = options.firstWhere(
      (option) => option.id == id,
      orElse: () => options.first,
    );
  }

  static void init(String? storedId) {
    selectById(storedId ?? defaultId);
  }

  static AppAccentOption byId(String id) {
    return options.firstWhere(
      (option) => option.id == id,
      orElse: () => options.first,
    );
  }
}
