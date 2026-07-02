import 'package:flutter/material.dart';

import 'app_accent_palette.dart';

/// Cardence kurumsal renk paleti.
/// Vurgu renkleri [AppAccentPalette] üzerinden dinamik; nötr ve semantik tonlar sabit.
class AppColors {
  AppColors._();

  // --- Primary (seçilebilir vurgu) ---
  static Color get primary => AppAccentPalette.selected.primary;
  static Color get primaryDark => AppAccentPalette.selected.primaryDark;
  static Color get primaryLight => AppAccentPalette.selected.primaryLight;
  static Color get primaryContainer => AppAccentPalette.selected.primaryContainer;
  static Color get onPrimaryContainer => AppAccentPalette.selected.onPrimaryContainer;
  static Color get primaryContainerDark =>
      AppAccentPalette.selected.primaryContainerDark;
  static Color get onPrimaryContainerDark =>
      AppAccentPalette.selected.onPrimaryContainerDark;
  static Color get primaryDarkTheme => AppAccentPalette.selected.primaryDarkTheme;

  // --- Secondary (nötr kurumsal gri) ---
  static const Color secondary = Color(0xFF4A5568);
  static const Color secondaryLight = Color(0xFF718096);

  // --- Background & Surface (light) ---
  static const Color backgroundLight = Color(0xFFF4F6F8);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFE6EBF0);
  static const Color outline = Color(0xFFB5BEC8);
  static const Color outlineVariant = Color(0xFFD8DEE6);

  // --- Dark theme ---
  static const Color backgroundDark = Color(0xFF0F1419);
  static const Color surfaceDark = Color(0xFF1A2028);
  static const Color surfaceVariantDark = Color(0xFF28303A);
  static const Color outlineDark = Color(0xFF4A5568);

  // --- Text (light) ---
  static const Color textPrimary = Color(0xFF1C2430);
  static const Color textSecondary = Color(0xFF5A6578);
  static const Color textDisabled = Color(0xFF94A0B0);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // --- Text (dark) ---
  static const Color textPrimaryDark = Color(0xFFECEFF4);
  static const Color textSecondaryDark = Color(0xFFA8B0BD);

  // --- Semantic ---
  static const Color success = Color(0xFF1F6B4F);
  static const Color error = Color(0xFFB42318);
  static const Color warning = Color(0xFFB54708);
  static Color get info => AppAccentPalette.selected.primary;

  // --- Onboarding ---
  static const Color onboardingBackground = Color(0xFFF4F6F8);
  static Color get onboardingAccent => AppAccentPalette.selected.primary;

  // --- Marka (sosyal giriş) ---
  static const Color linkedInBrand = Color(0xFF0A66C2);

  // --- Network graph kenar (edge) renkleri ---
  static Color get graphEdgeOwns => AppAccentPalette.selected.primary;
  static const Color graphEdgeSaved = Color(0xFF2E7D9A);
  static const Color graphEdgeSavedBy = Color(0xFF1F6B4F);
  static const Color graphEdgeEvent = Color(0xFF7A5AF8);
  static const Color graphEdgeCompany = Color(0xFF8A93A6);
  static const Color graphEdgeNeutral = Color(0xFFB5BEC8);

  // --- Network graph düğüm (node) accent renkleri ---
  static const Color graphCompanyNodeLight = Color(0xFFE6EEF2);
  static const Color graphCompanyNodeDark = Color(0xFF2A3340);
  static const Color graphEventNodeLight = Color(0xFFEAE4FD);
  static const Color graphEventNodeDark = Color(0xFF2E2747);
  static const Color graphEventAccent = Color(0xFF7A5AF8);
}
