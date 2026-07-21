import '../repositories/auth_repository.dart';

class DeleteAccount {
  const DeleteAccount(this._repository);

  final AuthRepository _repository;

  Future<void> call() => _repository.deleteAccount();
}
