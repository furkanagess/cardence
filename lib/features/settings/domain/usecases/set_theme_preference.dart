import '../entities/theme_preference.dart';
import '../repositories/theme_repository.dart';

class SetThemePreference {
  const SetThemePreference(this._repository);

  final ThemeRepository _repository;

  Future<void> call(ThemePreference preference) =>
      _repository.setThemePreference(preference);
}