import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Cardence uygulama teması (light + dark).
/// Kurumsal, resmi görünüm: lacivert vurgu, nötr yüzeyler, sakin tipografi.
class AppTheme {
  AppTheme._();

  static const double _radius = 10;

  static ThemeData get lightTheme => _buildTheme(Brightness.light);

  static ThemeData get darkTheme => _buildTheme(Brightness.dark);

  static ThemeData _buildTheme(Brightness brightness) {
    final isLight = brightness == Brightness.light;
    final scheme = isLight ? _lightColorScheme : _darkColorScheme;
    final textTheme = _textTheme(brightness);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      textTheme: textTheme,
      splashFactory: NoSplash.splashFactory,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      hoverColor: Colors.transparent,
      scaffoldBackgroundColor:
          isLight ? AppColors.backgroundLight : AppColors.backgroundDark,
      dividerTheme: DividerThemeData(
        color: isLight ? AppColors.outlineVariant : AppColors.outlineDark,
        thickness: 1,
      ),
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 1,
        backgroundColor: isLight ? AppColors.surfaceLight : AppColors.surfaceDark,
        foregroundColor:
            isLight ? AppColors.textPrimary : AppColors.textPrimaryDark,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: textTheme.titleLarge,
      ),
      iconButtonTheme: const IconButtonThemeData(
        style: ButtonStyle(
          overlayColor: WidgetStatePropertyAll<Color>(Colors.transparent),
        ),
      ),
      cardTheme: CardThemeData(
        color: isLight ? AppColors.surfaceLight : AppColors.surfaceDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_radius),
          side: BorderSide(
            color: isLight ? AppColors.outlineVariant : AppColors.outlineDark,
          ),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: isLight ? AppColors.surfaceLight : AppColors.surfaceDark,
        indicatorColor: isLight
            ? AppColors.primaryContainer
            : AppColors.primaryContainerDark,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return textTheme.labelMedium?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            );
          }
          return textTheme.labelMedium?.copyWith(
            color: isLight ? AppColors.textSecondary : AppColors.textSecondaryDark,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColors.primary);
          }
          return IconThemeData(
            color: isLight ? AppColors.textSecondary : AppColors.textSecondaryDark,
          );
        }),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: isLight ? AppColors.surfaceLight : AppColors.surfaceDark,
        selectedItemColor: AppColors.primary,
        unselectedItemColor:
            isLight ? AppColors.textSecondary : AppColors.textSecondaryDark,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: isLight ? AppColors.primary : AppColors.primaryDarkTheme,
          foregroundColor:
              isLight ? AppColors.textOnPrimary : AppColors.backgroundDark,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_radius),
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: isLight ? AppColors.primary : AppColors.primaryDarkTheme,
          foregroundColor:
              isLight ? AppColors.textOnPrimary : AppColors.backgroundDark,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_radius),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor:
              isLight ? AppColors.primary : AppColors.primaryDarkTheme,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor:
              isLight ? AppColors.primary : AppColors.primaryDarkTheme,
          side: BorderSide(
            color: isLight ? AppColors.primary : AppColors.primaryDarkTheme,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_radius),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isLight ? AppColors.surfaceLight : AppColors.surfaceVariantDark,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_radius),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_radius),
          borderSide: BorderSide(
            color: isLight ? AppColors.outline : AppColors.outlineDark,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_radius),
          borderSide: BorderSide(
            color: isLight ? AppColors.primary : AppColors.primaryDarkTheme,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_radius),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        labelStyle: TextStyle(
          color: isLight ? AppColors.textSecondary : AppColors.textSecondaryDark,
        ),
        hintStyle: TextStyle(
          color: isLight ? AppColors.textDisabled : AppColors.textSecondaryDark,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: isLight
            ? AppColors.primaryContainer
            : AppColors.primaryContainerDark,
        labelStyle: TextStyle(
          color: isLight
              ? AppColors.onPrimaryContainer
              : AppColors.onPrimaryContainerDark,
          fontWeight: FontWeight.w500,
        ),
        side: BorderSide.none,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: isLight ? AppColors.textPrimary : AppColors.surfaceVariantDark,
        contentTextStyle: TextStyle(
          color: isLight ? AppColors.textOnPrimary : AppColors.textPrimaryDark,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_radius),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: isLight ? AppColors.surfaceLight : AppColors.surfaceDark,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: isLight ? AppColors.surfaceLight : AppColors.surfaceDark,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: isLight ? AppColors.textSecondary : AppColors.textSecondaryDark,
        textColor: isLight ? AppColors.textPrimary : AppColors.textPrimaryDark,
      ),
    );
  }

  static ColorScheme get _lightColorScheme {
    return const ColorScheme.light(
      primary: AppColors.primary,
      onPrimary: AppColors.textOnPrimary,
      primaryContainer: AppColors.primaryContainer,
      onPrimaryContainer: AppColors.onPrimaryContainer,
      secondary: AppColors.secondary,
      onSecondary: AppColors.textOnPrimary,
      onSecondaryContainer: AppColors.textPrimary,
      surface: AppColors.surfaceLight,
      onSurface: AppColors.textPrimary,
      surfaceContainerHighest: AppColors.surfaceVariant,
      onSurfaceVariant: AppColors.textSecondary,
      outline: AppColors.outline,
      outlineVariant: AppColors.outlineVariant,
      error: AppColors.error,
      onError: AppColors.textOnPrimary,
    );
  }

  static ColorScheme get _darkColorScheme {
    return const ColorScheme.dark(
      primary: AppColors.primaryDarkTheme,
      onPrimary: AppColors.backgroundDark,
      primaryContainer: AppColors.primaryContainerDark,
      onPrimaryContainer: AppColors.onPrimaryContainerDark,
      secondary: AppColors.secondaryLight,
      onSecondary: AppColors.backgroundDark,
      surface: AppColors.surfaceDark,
      onSurface: AppColors.textPrimaryDark,
      surfaceContainerHighest: AppColors.surfaceVariantDark,
      onSurfaceVariant: AppColors.textSecondaryDark,
      outline: AppColors.outlineDark,
      error: AppColors.error,
      onError: AppColors.textOnPrimary,
    );
  }

  static TextTheme _textTheme(Brightness brightness) {
    final isLight = brightness == Brightness.light;
    final primary =
        isLight ? AppColors.textPrimary : AppColors.textPrimaryDark;
    final secondary =
        isLight ? AppColors.textSecondary : AppColors.textSecondaryDark;

    return TextTheme(
      headlineSmall: TextStyle(
        fontWeight: FontWeight.w600,
        color: primary,
        letterSpacing: -0.3,
      ),
      titleLarge: TextStyle(
        fontWeight: FontWeight.w600,
        color: primary,
        letterSpacing: -0.2,
      ),
      titleMedium: TextStyle(
        fontWeight: FontWeight.w600,
        color: primary,
      ),
      titleSmall: TextStyle(
        fontWeight: FontWeight.w600,
        color: primary,
        fontSize: 14,
      ),
      bodyLarge: TextStyle(color: primary, height: 1.45),
      bodyMedium: TextStyle(color: primary, height: 1.4),
      bodySmall: TextStyle(color: secondary, height: 1.35),
      labelLarge: TextStyle(
        fontWeight: FontWeight.w600,
        letterSpacing: 0.15,
        color: primary,
      ),
      labelMedium: TextStyle(
        fontWeight: FontWeight.w500,
        color: secondary,
      ),
      labelSmall: TextStyle(color: secondary),
    );
  }
}
