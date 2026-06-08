import '../repositories/auth_repository.dart';

class IsAuthenticated {
  const IsAuthenticated(this._repository);

  final AuthRepository _repository;

  Future<bool> call() => _repository.isAuthenticated();
}
