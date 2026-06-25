import 'package:shared_preferences/shared_preferences.dart';

const String _keyLocalePreference = 'locale_preference';

abstract class LocaleLocalDataSource {
  Future<String> getLocalePreference();
  Future<void> setLocalePreference(String value);
}

class LocaleLocalDataSourceImpl implements LocaleLocalDataSource {
  LocaleLocalDataSourceImpl(this._prefs);

  final SharedPreferences _prefs;

  @override
  Future<String> getLocalePreference() async {
    return _prefs.getString(_keyLocalePreference) ?? 'system';
  }

  @override
  Future<void> setLocalePreference(String value) async {
    await _prefs.setString(_keyLocalePreference, value);
  }
}
