import '../entities/auth_session.dart';
import '../repositories/auth_repository.dart';

class LoginWithLinkedIn {
  const LoginWithLinkedIn(this._repository);

  final AuthRepository _repository;

  Future<AuthSession> call({
    required String authorizationCode,
    required String redirectUri,
  }) =>
      _repository.loginWithLinkedIn(
        authorizationCode: authorizationCode,
        redirectUri: redirectUri,
      );
}
