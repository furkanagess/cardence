import '../entities/auth_session.dart';
import '../entities/last_login_credentials.dart';
import '../entities/restore_session_result.dart';
import '../entities/user_profile.dart';

abstract class AuthRepository {
  Future<AuthSession?> getStoredSession();

  Future<bool> isAuthenticated();

  Future<RestoreSessionResult> restoreSession();

  Future<AuthSession> loginWithEmail({
    required String email,
    required String password,
  });

  Future<AuthSession> loginWithPhone({
    required String phone,
    required String password,
  });

  Future<AuthSession> loginWithLinkedIn({
    required String authorizationCode,
    required String redirectUri,
  });

  Future<AuthSession> register({
    required String displayName,
    required String email,
    required String password,
    String? phone,
  });

  Future<void> forgotPassword({String? email, String? phone});

  Future<AuthSession> resetPassword({
    String? email,
    String? phone,
    required String otpCode,
    required String newPassword,
  });

  Future<UserProfile> getCurrentUser();

  Future<LastLoginCredentials> getLastLoginCredentials();

  Future<UserProfile> uploadProfilePhoto(String filePath);

  Future<void> completeOnboardingOnServer();

  Future<void> logout();

  Future<void> clearSession();
}
