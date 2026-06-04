import 'package:shared_preferences/shared_preferences.dart';

const String _keyThemeMode = 'theme_preference';

abstract class ThemeLocalDataSource {
  Future<String> getThemePreference();
  Future<void> setThemePreference(String value);
}

class ThemeLocalDataSourceImpl implements ThemeLocalDataSource {
  ThemeLocalDataSourceImpl(this._prefs);

  final SharedPreferences _prefs;

  @override
  Future<String> getThemePreference() async {
    return _prefs.getString(_keyThemeMode) ?? 'system';
  }

  @override
  Future<void> setThemePreference(String value) async {
    await _prefs.setString(_keyThemeMode, value);
  }
}
