import '../entities/theme_preference.dart';

/// Tema tercihini okur ve kaydeder.
abstract class ThemeRepository {
  Future<ThemePreference> getThemePreference();
  Future<void> setThemePreference(ThemePreference preference);
  Future<String> getAccentColorId();
  Future<void> setAccentColorId(String accentColorId);
}
