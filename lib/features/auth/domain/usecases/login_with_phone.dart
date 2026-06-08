import '../entities/auth_session.dart';
import '../repositories/auth_repository.dart';

class LoginWithPhone {
  const LoginWithPhone(this._repository);

  final AuthRepository _repository;

  Future<AuthSession> call({
    required String phone,
    required String password,
  }) =>
      _repository.loginWithPhone(
        phone: phone,
        password: password,
      );
}
