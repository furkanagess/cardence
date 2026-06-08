import '../entities/auth_session.dart';
import '../repositories/auth_repository.dart';

class LoginWithEmail {
  const LoginWithEmail(this._repository);

  final AuthRepository _repository;

  Future<AuthSession> call({
    required String email,
    required String password,
  }) =>
      _repository.loginWithEmail(
        email: email.trim().toLowerCase(),
        password: password,
      );
}
