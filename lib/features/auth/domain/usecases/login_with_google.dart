import '../entities/auth_session.dart';
import '../repositories/auth_repository.dart';

class LoginWithGoogle {
  const LoginWithGoogle(this._repository);

  final AuthRepository _repository;

  Future<AuthSession> call({required String idToken}) =>
      _repository.loginWithGoogle(idToken: idToken);
}
