import '../repositories/theme_repository.dart';

class SetAccentColorId {
  const SetAccentColorId(this._repository);

  final ThemeRepository _repository;

  Future<void> call(String accentColorId) =>
      _repository.setAccentColorId(accentColorId);
}
