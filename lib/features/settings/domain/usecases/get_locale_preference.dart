import '../repositories/locale_repository.dart';
import '../entities/locale_preference.dart';

class GetLocalePreference {
  const GetLocalePreference(this._repository);

  final LocaleRepository _repository;

  Future<LocalePreference> call() => _repository.getLocalePreference();
}
