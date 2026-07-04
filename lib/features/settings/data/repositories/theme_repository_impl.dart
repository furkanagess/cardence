import '../../domain/entities/theme_preference.dart';
import '../../domain/repositories/theme_repository.dart';
import '../datasources/theme_local_datasource.dart';
import '../../../../core/theme/app_accent_palette.dart';

class ThemeRepositoryImpl implements ThemeRepository {
  ThemeRepositoryImpl(this._dataSource);

  final ThemeLocalDataSource _dataSource;

  static ThemePreference _fromString(String value) {
    switch (value) {
      case 'light':
        return ThemePreference.light;
      case 'dark':
        return ThemePreference.dark;
      default:
        return ThemePreference.system;
    }
  }

  static String _toString(ThemePreference p) {
    switch (p) {
      case ThemePreference.light:
        return 'light';
      case ThemePreference.dark:
        return 'dark';
      case ThemePreference.system:
        return 'system';
    }
  }

  @override
  Future<ThemePreference> getThemePreference() async {
    final s = await _dataSource.getThemePreference();
    return _fromString(s);
  }

  @override
  Future<void> setThemePreference(ThemePreference preference) async {
    await _dataSource.setThemePreference(_toString(preference));
  }

  @override
  Future<String> getAccentColorId() async {
    final id = await _dataSource.getAccentColorId();
    return AppAccentPalette.normalizeId(id);
  }

  @override
  Future<void> setAccentColorId(String accentColorId) async {
    await _dataSource.setAccentColorId(
      AppAccentPalette.normalizeId(accentColorId),
    );
  }
}
