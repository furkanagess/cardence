import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Kayıtlı kart detay ekranı renkleri — light/dark uyumlu.
abstract final class SavedCardDetailTheme {
  static Brightness brightnessOf(BuildContext context) =>
      Theme.of(context).brightness;

  static Color background(BuildContext context) =>
      AppColors.savedCardDetailBackgroundFor(brightnessOf(context));

  static Color surface(BuildContext context) =>
      AppColors.savedCardDetailSurfaceFor(brightnessOf(context));

  static Color accentSurface(BuildContext context) =>
      AppColors.savedCardDetailAccentSurfaceFor(brightnessOf(context));

  static Color chipSurface(BuildContext context) =>
      AppColors.savedCardDetailChipSurfaceFor(brightnessOf(context));

  static Color textPrimary(BuildContext context) =>
      AppColors.savedCardDetailTextPrimaryFor(brightnessOf(context));

  static Color textSecondary(BuildContext context) =>
      AppColors.savedCardDetailTextSecondaryFor(brightnessOf(context));

  static Color outline(BuildContext context) =>
      AppColors.savedCardDetailOutlineFor(brightnessOf(context));

  static Color cardShadow(BuildContext context) =>
      AppColors.savedCardDetailShadowFor(brightnessOf(context));
}
