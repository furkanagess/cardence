import 'package:flutter/material.dart';

/// Cardence kurumsal renk paleti.
/// Dijital kartvizit ve resmi iletişim bağlamında: lacivert + nötr gri,
/// sakin kontrast ve okunabilirlik.
class AppColors {
  AppColors._();

  // --- Primary (kurumsal lacivert) ---
  static const Color primary = Color(0xFF1B365D);
  static const Color primaryDark = Color(0xFF122640);
  static const Color primaryLight = Color(0xFF2E4A73);

  // --- Primary container (yumuşak mavi-gri ton) ---
  static const Color primaryContainer = Color(0xFFD6DEE8);
  static const Color onPrimaryContainer = Color(0xFF1B365D);
  static const Color primaryContainerDark = Color(0xFF243548);
  static const Color onPrimaryContainerDark = Color(0xFFD6DEE8);

  // --- Secondary (nötr kurumsal gri) ---
  static const Color secondary = Color(0xFF4A5568);
  static const Color secondaryLight = Color(0xFF718096);

  // --- Background & Surface (light) ---
  static const Color backgroundLight = Color(0xFFF4F5F7);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFE8EBF0);
  static const Color outline = Color(0xFFB8C0CC);
  static const Color outlineVariant = Color(0xFFDDE2E9);

  // --- Dark theme ---
  static const Color backgroundDark = Color(0xFF0F1419);
  static const Color surfaceDark = Color(0xFF1A2028);
  static const Color surfaceVariantDark = Color(0xFF28303A);
  static const Color outlineDark = Color(0xFF4A5568);
  static const Color primaryDarkTheme = Color(0xFF8FA8C4);

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
  static const Color info = Color(0xFF1E4A6E);

  // --- Onboarding ---
  static const Color onboardingBackground = Color(0xFFF4F5F7);
  static const Color onboardingAccent = primary;
}
