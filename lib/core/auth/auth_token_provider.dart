import '../../features/auth/data/datasources/auth_local_datasource.dart';
import '../network/auth_api_exception.dart';
import 'auth_token_coordinator.dart';

/// Repository katmanında geçerli access token almak için yardımcı.
class AuthTokenProvider {
  AuthTokenProvider(this._authLocal);

  final AuthLocalDataSource _authLocal;

  Future<String?> tryAccessToken() async {
    final coordinator = AuthTokenCoordinator.instance;
    if (coordinator != null) {
      return coordinator.getValidAccessToken();
    }

    final session = await _authLocal.getSession();
    if (session == null || session.accessToken.isEmpty) return null;
    return session.accessToken;
  }

  Future<String> requireAccessToken() async {
    final token = await tryAccessToken();
    if (token == null || token.isEmpty) {
      throw AuthApiException('Oturum bulunamadı. Lütfen tekrar giriş yapın.');
    }
    return token;
  }
}
