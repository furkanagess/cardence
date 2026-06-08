import '../entities/auth_session.dart';
import '../repositories/auth_repository.dart';

class RegisterUser {
  const RegisterUser(this._repository);

  final AuthRepository _repository;

  Future<AuthSession> call({
    required String displayName,
    required String email,
    required String password,
    String? phone,
  }) =>
      _repository.register(
        displayName: displayName,
        email: email,
        password: password,
        phone: phone,
      );
}
