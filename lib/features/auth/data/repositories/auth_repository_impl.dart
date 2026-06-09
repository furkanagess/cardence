import '../../domain/entities/auth_session.dart';
import '../../domain/entities/restore_session_result.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/auth_session_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required AuthRemoteDataSource remote,
    required AuthLocalDataSource local,
    Future<void> Function(UserProfile profile)? onProfileSynced,
    Future<void> Function()? onLogout,
  })  : _remote = remote,
        _local = local,
        _onProfileSynced = onProfileSynced,
        _onLogout = onLogout;

  final AuthRemoteDataSource _remote;
  final AuthLocalDataSource _local;
  final Future<void> Function(UserProfile profile)? _onProfileSynced;
  final Future<void> Function()? _onLogout;

  Future<AuthSession> _persist(AuthSessionModel model) async {
    await _local.saveSession(model);
    return model.toEntity();
  }

  AuthSessionModel _mergeProfile(AuthSessionModel session, UserProfile profile) {
    return AuthSessionModel(
      accessToken: session.accessToken,
      refreshToken: session.refreshToken,
      userId: session.userId,
      expiresIn: session.expiresIn,
      email: profile.email ?? session.email,
      phone: profile.phone ?? session.phone,
      displayName: profile.displayName ?? session.displayName,
    );
  }

  Future<UserProfile> _fetchAndPersistProfile(AuthSessionModel session) async {
    final profile = await _remote.getMe(session.accessToken);
    final entity = profile.toEntity();
    final enriched = _mergeProfile(session, entity);
    await _local.saveSession(enriched);
    await _onProfileSynced?.call(entity);
    return entity;
  }

  Future<AuthSession?> _tryRefresh(AuthSession session) async {
    final refreshToken = session.refreshToken;
    if (refreshToken == null || refreshToken.isEmpty) return null;
    try {
      final model = await _remote.refreshAuthentication(refreshToken);
      return _persist(model);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<AuthSession?> getStoredSession() async {
    final model = await _local.getSession();
    return model?.toEntity();
  }

  @override
  Future<bool> isAuthenticated() async {
    final session = await getStoredSession();
    return session?.isValid ?? false;
  }

  @override
  Future<RestoreSessionResult> restoreSession() async {
    final session = await getStoredSession();
    if (session == null || !session.isValid) {
      return const RestoreSessionResult(isAuthenticated: false);
    }

    try {
      final profile = await _fetchAndPersistProfile(
        AuthSessionModel.fromEntity(session),
      );
      return RestoreSessionResult(
        isAuthenticated: true,
        onboardingCompleted: profile.onboardingCompleted,
      );
    } on AuthApiException catch (e) {
      if (e.isUnauthorized) {
        final refreshed = await _tryRefresh(session);
        if (refreshed != null) {
          try {
            final profile = await _fetchAndPersistProfile(
              AuthSessionModel.fromEntity(refreshed),
            );
            return RestoreSessionResult(
              isAuthenticated: true,
              onboardingCompleted: profile.onboardingCompleted,
            );
          } catch (_) {
            await clearSession();
            return const RestoreSessionResult(isAuthenticated: false);
          }
        }
      }
      await clearSession();
      return const RestoreSessionResult(isAuthenticated: false);
    } catch (_) {
      await clearSession();
      return const RestoreSessionResult(isAuthenticated: false);
    }
  }

  @override
  Future<AuthSession> loginWithEmail({
    required String email,
    required String password,
  }) async {
    final model = await _remote.authenticateWithEmail(
      email: email,
      password: password,
    );
    final session = await _persist(model);
    try {
      await _fetchAndPersistProfile(model);
    } catch (_) {}
    return session;
  }

  @override
  Future<AuthSession> loginWithPhone({
    required String phone,
    required String password,
  }) async {
    final model = await _remote.loginWithPhone(
      phone: phone,
      password: password,
    );
    final session = await _persist(model);
    try {
      await _fetchAndPersistProfile(model);
    } catch (_) {}
    return session;
  }

  @override
  Future<AuthSession> register({
    required String displayName,
    required String email,
    required String password,
    String? phone,
  }) async {
    final model = await _remote.register(
      displayName: displayName,
      email: email,
      password: password,
      phone: phone,
    );
    final session = await _persist(model);
    try {
      await _fetchAndPersistProfile(model);
    } catch (_) {}
    return session;
  }

  @override
  Future<void> forgotPassword({String? email, String? phone}) =>
      _remote.forgotPassword(email: email, phone: phone);

  @override
  Future<AuthSession> resetPassword({
    String? email,
    String? phone,
    required String otpCode,
    required String newPassword,
  }) async {
    final model = await _remote.resetPassword(
      email: email,
      phone: phone,
      otpCode: otpCode,
      newPassword: newPassword,
    );
    final session = await _persist(model);
    try {
      await _fetchAndPersistProfile(model);
    } catch (_) {}
    return session;
  }

  @override
  Future<UserProfile> getCurrentUser() async {
    final session = await getStoredSession();
    if (session == null || !session.isValid) {
      throw AuthApiException('Oturum bulunamadı. Lütfen tekrar giriş yapın.');
    }
    return _fetchAndPersistProfile(AuthSessionModel.fromEntity(session));
  }

  @override
  Future<UserProfile> uploadProfilePhoto(String filePath) async {
    final session = await getStoredSession();
    if (session == null || !session.isValid) {
      throw AuthApiException('Oturum bulunamadı. Lütfen tekrar giriş yapın.');
    }

    final profile = await _remote.uploadProfilePhoto(
      filePath: filePath,
      accessToken: session.accessToken,
    );
    final entity = profile.toEntity();
    final enriched = _mergeProfile(
      AuthSessionModel.fromEntity(session),
      entity,
    );
    await _local.saveSession(enriched);
    await _onProfileSynced?.call(entity);
    return entity;
  }

  @override
  Future<void> completeOnboardingOnServer() async {
    final session = await getStoredSession();
    if (session == null || !session.isValid) {
      throw AuthApiException('Oturum bulunamadı.');
    }
    final profile = await _remote.completeOnboarding(session.accessToken);
    final entity = profile.toEntity();
    final enriched = _mergeProfile(
      AuthSessionModel.fromEntity(session),
      entity,
    );
    await _local.saveSession(enriched);
    await _onProfileSynced?.call(entity);
  }

  @override
  Future<void> logout() => clearSession();

  @override
  Future<void> clearSession() async {
    await _onLogout?.call();
    await _local.clearSession();
  }
}
