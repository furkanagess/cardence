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

  /// Bilinçli tam siyah yüzeyler (kart detay panelleri vb.).
  static const Color pureBlack = Color(0xFF000000);

  // --- Kart detay (açık zemin + siyah iç kartlar) ---
  static const Color profileDetailBackground = Color(0xFF141A22);
  static const Color profileDetailSurface = pureBlack;
  static const Color profileDetailSurfaceElevated = Color(0xFF0A0E14);
  static const Color profileDetailBorder = Color(0xFF2A3340);

  /// Tüm uygulama AppBar'ları — [CardenceAppBar] ve [AppBarTheme] ile paylaşılır.
  /// Scaffold arka planından bir ton koyu.
  static const Color appBarBackgroundLight = Color(0xFFE6EBF0);
  static const Color appBarBackgroundDark = Color(0xFF0A0E14);

  static Color appBarBackgroundFor(Brightness brightness) =>
      brightness == Brightness.light
          ? appBarBackgroundLight
          : appBarBackgroundDark;

  static Color appBarForegroundFor(Brightness brightness) =>
      brightness == Brightness.light ? textPrimary : textPrimaryDark;

  static Color appBarBorderColorFor(Brightness brightness) =>
      brightness == Brightness.light ? outlineVariant : profileDetailBorder;

  static const double appBarElevation = 2;

  static Color appBarShadowColor(Brightness brightness) => textPrimary
      .withValues(alpha: brightness == Brightness.light ? 0.18 : 0.35);

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

  // --- Settings ---
  static const Color settingsScreenBackgroundLight = Color(0xFFF8F9FD);
  static const Color settingsScreenBackgroundDark = backgroundDark;

  // --- Kayıtlı kart detay ---
  static const Color savedCardDetailBackgroundLight = Color(0xFFF5F7FB);
  static const Color savedCardDetailBackgroundDark = backgroundDark;
  static const Color savedCardDetailSurfaceLight = surfaceLight;
  static const Color savedCardDetailSurfaceDark = surfaceDark;
  static const Color savedCardDetailAccentSurfaceLight = Color(0xFFEEF2FF);
  static const Color savedCardDetailAccentSurfaceDark = Color(0xFF232D38);
  static const Color savedCardDetailChipSurfaceLight = Color(0xFFE8EEF5);
  static const Color savedCardDetailChipSurfaceDark = surfaceVariantDark;

  /// Geriye dönük uyumluluk (açık tema).
  static const Color savedCardDetailBackground = savedCardDetailBackgroundLight;
  static const Color savedCardDetailSurface = savedCardDetailSurfaceLight;
  static const Color savedCardDetailAccentSurface =
      savedCardDetailAccentSurfaceLight;
  static const Color savedCardDetailChipSurface = savedCardDetailChipSurfaceLight;

  static Color savedCardDetailBackgroundFor(Brightness brightness) =>
      brightness == Brightness.light
          ? savedCardDetailBackgroundLight
          : savedCardDetailBackgroundDark;

  static Color savedCardDetailSurfaceFor(Brightness brightness) =>
      brightness == Brightness.light
          ? savedCardDetailSurfaceLight
          : savedCardDetailSurfaceDark;

  static Color savedCardDetailAccentSurfaceFor(Brightness brightness) {
    if (brightness == Brightness.light) {
      return savedCardDetailAccentSurfaceLight;
    }
    return Color.alphaBlend(
      primary.withValues(alpha: 0.12),
      savedCardDetailAccentSurfaceDark,
    );
  }

  static Color savedCardDetailChipSurfaceFor(Brightness brightness) =>
      brightness == Brightness.light
          ? savedCardDetailChipSurfaceLight
          : savedCardDetailChipSurfaceDark;

  static Color savedCardDetailTextPrimaryFor(Brightness brightness) =>
      brightness == Brightness.light ? textPrimary : textPrimaryDark;

  static Color savedCardDetailTextSecondaryFor(Brightness brightness) =>
      brightness == Brightness.light ? textSecondary : textSecondaryDark;

  static Color savedCardDetailOutlineFor(Brightness brightness) =>
      brightness == Brightness.light ? outlineVariant : outlineDark;

  static Color savedCardDetailShadowFor(Brightness brightness) =>
      textPrimary.withValues(alpha: brightness == Brightness.light ? 0.04 : 0.28);

  // --- Onboarding ---
  static const Color onboardingBackground = backgroundLight;
  static Color get onboardingAccent => AppAccentPalette.selected.primary;

  // --- Marka (sosyal giriş) ---
  static const Color linkedInBrand = Color(0xFF0A66C2);

  // --- Network graph canvas ---
  static const Color graphCanvasBackgroundDark = Color(0xFF000000);
  static const Color graphCanvasBackgroundLight = Color(0xFFF4F6F8);
  static const Color graphCanvasGridDark = Color(0xFF1A1F26);
  static const Color graphCanvasGridLight = Color(0xFFDCE2EA);
  static const Color graphCanvasGridAccentDark = Color(0xFF252B34);
  static const Color graphCanvasGridAccentLight = Color(0xFFC5CDD8);
  static const Color graphNodeLabelBackgroundDark = Color(0xE614181E);
  static const Color graphNodeLabelBackgroundLight = Color(0xF5FFFFFF);
  static const Color graphNodeLabelBorderDark = Color(0xFF2E3640);
  static const Color graphNodeLabelBorderLight = Color(0xFFD8DEE6);
  static const Color graphOwnCardAccent = Color(0xFFE8B84A);

  /// Geriye dönük uyumluluk — koyu canvas.
  static const Color graphCanvasBackground = graphCanvasBackgroundDark;
  static const Color graphCanvasGrid = graphCanvasGridDark;
  static const Color graphCanvasGridAccent = graphCanvasGridAccentDark;
  static const Color graphNodeLabelBackground = graphNodeLabelBackgroundDark;
  static const Color graphNodeLabelBorder = graphNodeLabelBorderDark;

  static Color graphCanvasBackgroundFor(Brightness brightness) =>
      brightness == Brightness.dark
          ? graphCanvasBackgroundDark
          : graphCanvasBackgroundLight;

  static Color graphCanvasGridFor(Brightness brightness) =>
      brightness == Brightness.dark ? graphCanvasGridDark : graphCanvasGridLight;

  static Color graphCanvasGridAccentFor(Brightness brightness) =>
      brightness == Brightness.dark
          ? graphCanvasGridAccentDark
          : graphCanvasGridAccentLight;

  static Color graphNodeLabelBackgroundFor(Brightness brightness) =>
      brightness == Brightness.dark
          ? graphNodeLabelBackgroundDark
          : graphNodeLabelBackgroundLight;

  static Color graphNodeLabelBorderFor(Brightness brightness) =>
      brightness == Brightness.dark
          ? graphNodeLabelBorderDark
          : graphNodeLabelBorderLight;

  static Color graphCanvasPrimaryTextFor(Brightness brightness) =>
      brightness == Brightness.dark ? textPrimaryDark : textPrimary;

  static Color graphCanvasSecondaryTextFor(Brightness brightness) =>
      brightness == Brightness.dark ? textSecondaryDark : textSecondary;

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
