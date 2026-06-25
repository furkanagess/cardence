import '../entities/locale_preference.dart';

abstract class LocaleRepository {
  Future<LocalePreference> getLocalePreference();
  Future<void> setLocalePreference(LocalePreference preference);
}
