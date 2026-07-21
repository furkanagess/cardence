import '../entities/auth_session.dart';
import '../repositories/auth_repository.dart';

class LoginWithApple {
  const LoginWithApple(this._repository);

  final AuthRepository _repository;

  Future<AuthSession> call({
    required String identityToken,
    String? authorizationCode,
    String? givenName,
    String? familyName,
  }) =>
      _repository.loginWithApple(
        identityToken: identityToken,
        authorizationCode: authorizationCode,
        givenName: givenName,
        familyName: familyName,
      );
}
