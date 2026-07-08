import 'package:flutter/material.dart';
import '../../../../core/l10n/l10n_extensions.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/locale_preference.dart';
import '../../domain/entities/theme_preference.dart';
import 'settings_locale_selector.dart';
import 'settings_surface_card.dart';
import 'settings_theme_selector.dart';

/// Tema ve dil seçimlerini tek kartta gruplar.
class SettingsAppearancePanel extends StatelessWidget {
  const SettingsAppearancePanel({
    super.key,
    required this.currentTheme,
    required this.onThemeChanged,
    required this.currentLocale,
    required this.onLocaleChanged,
  });

  final ThemePreference currentTheme;
  final ValueChanged<ThemePreference> onThemeChanged;
  final LocalePreference currentLocale;
  final ValueChanged<LocalePreference> onLocaleChanged;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return SettingsSurfaceCard(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            context.l10n.temaModu,
            style: textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          SettingsThemeSelector(
            current: currentTheme,
            onChanged: onThemeChanged,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Divider(
              height: 1,
              thickness: 1,
              color: isDark
                  ? AppColors.outlineDark.withValues(alpha: 0.35)
                  : AppColors.outlineVariant.withValues(alpha: 0.85),
            ),
          ),
          SettingsLocaleSelector(
            current: currentLocale,
            onChanged: onLocaleChanged,
          ),
        ],
      ),
    );
  }
}
