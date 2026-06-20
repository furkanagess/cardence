import '../entities/last_login_credentials.dart';
import '../repositories/auth_repository.dart';

class GetLastLoginCredentials {
  const GetLastLoginCredentials(this._repository);

  final AuthRepository _repository;

  Future<LastLoginCredentials> call() => _repository.getLastLoginCredentials();
}
