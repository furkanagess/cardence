import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Splash ekranı ve native splash ile uyumlu marka renkleri / varlıkları.
abstract final class SplashTheme {
  static const String lightLogoAsset =
      'assets/icons/cardence_logo-removebg.png';
  static const String darkLogoAsset =
      'assets/icons/cardence_logo_splash_white.png';

  static Color background(Brightness brightness) =>
      brightness == Brightness.dark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight;

  static String logoAsset(Brightness brightness) =>
      brightness == Brightness.dark ? darkLogoAsset : lightLogoAsset;

  static Brightness resolveBrightness({
    required ThemeMode themeMode,
    required Brightness platformBrightness,
  }) {
    return switch (themeMode) {
      ThemeMode.light => Brightness.light,
      ThemeMode.dark => Brightness.dark,
      ThemeMode.system => platformBrightness,
    };
  }
}
