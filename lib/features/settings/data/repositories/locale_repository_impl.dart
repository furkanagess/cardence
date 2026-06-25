import '../../domain/entities/locale_preference.dart';
import '../../domain/repositories/locale_repository.dart';
import '../datasources/locale_local_datasource.dart';

class LocaleRepositoryImpl implements LocaleRepository {
  LocaleRepositoryImpl(this._dataSource);

  final LocaleLocalDataSource _dataSource;

  static LocalePreference _fromString(String value) {
    switch (value) {
      case 'tr':
        return LocalePreference.turkish;
      case 'en':
        return LocalePreference.english;
      default:
        return LocalePreference.system;
    }
  }

  static String _toString(LocalePreference preference) {
    switch (preference) {
      case LocalePreference.turkish:
        return 'tr';
      case LocalePreference.english:
        return 'en';
      case LocalePreference.system:
        return 'system';
    }
  }

  @override
  Future<LocalePreference> getLocalePreference() async {
    final stored = await _dataSource.getLocalePreference();
    return _fromString(stored);
  }

  @override
  Future<void> setLocalePreference(LocalePreference preference) async {
    await _dataSource.setLocalePreference(_toString(preference));
  }
}
