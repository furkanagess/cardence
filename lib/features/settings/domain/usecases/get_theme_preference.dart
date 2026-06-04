import '../entities/theme_preference.dart';
import '../repositories/theme_repository.dart';

class GetThemePreference {
  const GetThemePreference(this._repository);

  final ThemeRepository _repository;

  Future<ThemePreference> call() => _repository.getThemePreference();
}
