import '../repositories/theme_repository.dart';

class GetAccentColorId {
  const GetAccentColorId(this._repository);

  final ThemeRepository _repository;

  Future<String> call() => _repository.getAccentColorId();
}
