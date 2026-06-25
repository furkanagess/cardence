import '../repositories/locale_repository.dart';
import '../entities/locale_preference.dart';

class SetLocalePreference {
  const SetLocalePreference(this._repository);

  final LocaleRepository _repository;

  Future<void> call(LocalePreference preference) =>
      _repository.setLocalePreference(preference);
}
