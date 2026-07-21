import 'dart:async';

import '../../../../core/auth/auth_token_coordinator.dart';
import '../../../../core/auth/refresh_session_outcome.dart';
import '../../../../core/media/authenticated_image_loader.dart';
import '../../domain/entities/auth_session.dart';
import '../../domain/entities/last_login_credentials.dart';
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

  AuthTokenCoordinator? get _coordinator => AuthTokenCoordinator.instance;

  Future<AuthSession> _persist(AuthSessionModel model) async {
    final withExpiry = model.withComputedExpiry();
    await _local.saveSession(withExpiry);
    _coordinator?.resetAfterLogin();
    return withExpiry.toEntity();
  }

  Future<void> _rememberLogin({
    String? email,
    String? phone,
    LastLoginMethod? method,
  }) async {
    await _local.saveLastLoginCredentials(
      email: email?.trim().isNotEmpty == true ? email!.trim().toLowerCase() : null,
      phone: phone?.trim().isNotEmpty == true ? phone!.trim() : null,
      method: method,
    );
  }

  AuthSessionModel _mergeProfile(AuthSessionModel session, UserProfile profile) {
    return AuthSessionModel(
      accessToken: session.accessToken,
      refreshToken: session.refreshToken,
      userId: session.userId,
      expiresIn: session.expiresIn,
      accessTokenExpiresAt: session.accessTokenExpiresAt,
      email: profile.email ?? session.email,
      phone: profile.phone ?? session.phone,
      displayName: profile.displayName ?? session.displayName,
    );
  }

  static const _profileSyncTimeout = Duration(seconds: 10);

  Future<UserProfile> _fetchAndPersistProfile(AuthSessionModel session) async {
    final token = await _coordinator?.getValidAccessToken() ?? session.accessToken;
    final profile = await _remote.getMe(token);
    final entity = profile.toEntity();
    final enriched = _mergeProfile(session, entity);
    await _local.saveSession(enriched);
    await _local.saveCachedProfile(profile);
    await _onProfileSynced?.call(entity);
    return entity;
  }

  /// Login sonrası profil senkronu; takılırsa login akışını bloklamaz.
  Future<void> _syncProfileAfterLogin(AuthSessionModel session) async {
    try {
      await _fetchAndPersistProfile(session.withComputedExpiry())
          .timeout(_profileSyncTimeout);
    } catch (_) {}
  }

  UserProfile _profileFromSession(AuthSession session) {
    return UserProfile(
      userId: session.userId,
      displayName: session.displayName,
      email: session.email,
      phone: session.phone,
    );
  }

  Future<UserProfile?> _readCachedProfile() async {
    final cached = await _local.getCachedProfile();
    return cached?.toEntity();
  }

  Future<UserProfile> _resolveProfile(AuthSessionModel session) async {
    final cached = await _readCachedProfile();
    if (cached != null) {
      unawaited(_refreshProfileInBackground(session));
      return cached;
    }

    try {
      return await _fetchAndPersistProfile(session);
    } on AuthApiException catch (e) {
      if (e.isUnauthorized) {
        final outcome = await _coordinator?.refreshSession() ??
            const RefreshSessionOutcome.failed();
        if (outcome.refreshed) {
          final updated = await _local.getSession();
          if (updated != null) {
            return _fetchAndPersistProfile(updated);
          }
        }
        if (outcome.invalidRefreshToken) {
          throw AuthApiException('Oturum bulunamadı. Lütfen tekrar giriş yapın.');
        }
        return _profileFromSession(session.toEntity());
      }

      return _profileFromSession(session.toEntity());
    } catch (_) {
      return _profileFromSession(session.toEntity());
    }
  }

  Future<void> _refreshProfileInBackground(AuthSessionModel session) async {
    try {
      await _fetchAndPersistProfile(session);
    } catch (_) {}
  }

  @override
  Future<AuthSession?> getStoredSession() async {
    final model = await _local.getSession();
    return model?.toEntity();
  }

  @override
  Future<bool> isAuthenticated() async {
    final stored = await _local.getSession();
    if (stored == null || !stored.canRestoreSession) return false;
    if (stored.accessToken.isNotEmpty) return true;

    final outcome = await _coordinator?.refreshSession() ??
        const RefreshSessionOutcome.failed();
    return outcome.refreshed;
  }

  @override
  Future<RestoreSessionResult> restoreSession() async {
    var stored = await _local.getSession();
    if (stored == null || !stored.canRestoreSession) {
      return const RestoreSessionResult(isAuthenticated: false);
    }

    stored = await _ensureFreshAccessToken(stored);
    if (!stored.canRestoreSession) {
      return const RestoreSessionResult(isAuthenticated: false);
    }

    final cached = await _readCachedProfile();
    if (cached != null) {
      unawaited(_refreshProfileInBackground(stored));
      return RestoreSessionResult(
        isAuthenticated: true,
        onboardingCompleted: cached.onboardingCompleted,
      );
    }

    try {
      final profile = await _resolveProfile(stored);
      return RestoreSessionResult(
        isAuthenticated: true,
        onboardingCompleted: profile.onboardingCompleted,
      );
    } on AuthApiException catch (e) {
      if (e.isUnauthorized) {
        final outcome = await _coordinator?.refreshSession() ??
            const RefreshSessionOutcome.failed();
        if (outcome.refreshed) {
          final updated = await _local.getSession();
          if (updated != null) {
            try {
              final profile = await _resolveProfile(updated);
              return RestoreSessionResult(
                isAuthenticated: true,
                onboardingCompleted: profile.onboardingCompleted,
              );
            } catch (_) {}
          }
        }
        if (outcome.invalidRefreshToken) {
          await clearSession();
          return const RestoreSessionResult(isAuthenticated: false);
        }
        return RestoreSessionResult(
          isAuthenticated: true,
          onboardingCompleted: cached?.onboardingCompleted,
        );
      }
      return RestoreSessionResult(
        isAuthenticated: true,
        onboardingCompleted: cached?.onboardingCompleted,
      );
    } catch (_) {
      return const RestoreSessionResult(
        isAuthenticated: true,
        onboardingCompleted: null,
      );
    }
  }

  Future<AuthSessionModel> _ensureFreshAccessToken(
    AuthSessionModel stored,
  ) async {
    final needsRefresh =
        stored.accessToken.isEmpty || stored.isAccessTokenStale;
    final hasRefresh = stored.refreshToken?.isNotEmpty ?? false;
    if (!needsRefresh || !hasRefresh) return stored;

    final outcome = await _coordinator?.refreshSession() ??
        const RefreshSessionOutcome.failed();
    if (!outcome.refreshed) {
      return stored;
    }

    _coordinator?.resetAfterLogin();
    final updated = await _local.getSession();
    return updated ?? stored;
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
    await _syncProfileAfterLogin(model);
    await _rememberLogin(
      email: email,
      method: LastLoginMethod.email,
    );
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
    await _syncProfileAfterLogin(model);
    await _rememberLogin(
      phone: phone,
      method: LastLoginMethod.phone,
    );
    return session;
  }

  // OTP (geçici kapalı): PhoneLoginResult / otpCode yolu

  @override
  Future<AuthSession> loginWithLinkedIn({
    required String authorizationCode,
    required String redirectUri,
  }) async {
    final model = await _remote.loginWithLinkedIn(
      authorizationCode: authorizationCode,
      redirectUri: redirectUri,
    );
    final session = await _persist(model);
    await _syncProfileAfterLogin(model);
    await _rememberLogin(method: LastLoginMethod.linkedin);
    return session;
  }

  @override
  Future<AuthSession> loginWithGoogle({required String idToken}) async {
    final model = await _remote.loginWithGoogle(idToken: idToken);
    final session = await _persist(model);
    await _syncProfileAfterLogin(model);
    await _rememberLogin(method: LastLoginMethod.google);
    return session;
  }

  @override
  Future<AuthSession> loginWithApple({
    required String identityToken,
    String? authorizationCode,
    String? givenName,
    String? familyName,
  }) async {
    final model = await _remote.loginWithApple(
      identityToken: identityToken,
      authorizationCode: authorizationCode,
      givenName: givenName,
      familyName: familyName,
    );
    final session = await _persist(model);
    await _syncProfileAfterLogin(model);
    await _rememberLogin(method: LastLoginMethod.apple);
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
    await _syncProfileAfterLogin(model);
    await _rememberLogin(
      email: email,
      phone: phone,
      method: LastLoginMethod.email,
    );
    return session;
  }

  @override
  Future<void> forgotPassword({String? email, String? phone}) =>
      _remote.forgotPassword(email: email, phone: phone);

  @override
  Future<AuthSession> resetPassword({
    String? email,
    String? phone,
    String? otpCode,
    String? resetToken,
    required String newPassword,
  }) async {
    final model = await _remote.resetPassword(
      email: email,
      phone: phone,
      otpCode: otpCode,
      resetToken: resetToken,
      newPassword: newPassword,
    );
    final session = await _persist(model);
    try {
      await _fetchAndPersistProfile(model.withComputedExpiry());
    } catch (_) {}
    await _rememberLogin(
      email: email,
      phone: phone,
      method: email != null ? LastLoginMethod.email : LastLoginMethod.phone,
    );
    return session;
  }

  @override
  Future<UserProfile> getCurrentUser() async {
    final session = await getStoredSession();
    if (session == null || !session.isValid) {
      throw AuthApiException('Oturum bulunamadı. Lütfen tekrar giriş yapın.');
    }
    return _resolveProfile(AuthSessionModel.fromEntity(session));
  }

  @override
  Future<UserProfile> refreshCurrentUser() async {
    final session = await getStoredSession();
    if (session == null || !session.isValid) {
      throw AuthApiException('Oturum bulunamadı. Lütfen tekrar giriş yapın.');
    }

    try {
      return await _fetchAndPersistProfile(AuthSessionModel.fromEntity(session));
    } on AuthApiException catch (e) {
      if (e.isUnauthorized) {
        final outcome = await _coordinator?.refreshSession() ??
            const RefreshSessionOutcome.failed();
        if (outcome.refreshed) {
          final updated = await _local.getSession();
          if (updated != null) {
            return _fetchAndPersistProfile(updated);
          }
        }
        if (outcome.invalidRefreshToken) {
          throw AuthApiException('Oturum bulunamadı. Lütfen tekrar giriş yapın.');
        }
        rethrow;
      }
      rethrow;
    }
  }

  @override
  Future<LastLoginCredentials> getLastLoginCredentials() async {
    return _local.getLastLoginCredentials();
  }

  @override
  Future<UserProfile> uploadProfilePhoto(String filePath) async {
    final token = await _coordinator?.getValidAccessToken();
    final session = await getStoredSession();
    if (token == null || session == null || !session.isValid) {
      throw AuthApiException('Oturum bulunamadı. Lütfen tekrar giriş yapın.');
    }

    final profile = await _remote.uploadProfilePhoto(
      filePath: filePath,
      accessToken: token,
    );
    final entity = profile.toEntity();
    if (entity.photoUrl != null && entity.photoUrl!.trim().isNotEmpty) {
      AuthenticatedImageLoader.evictAllVariants(entity.photoUrl!.trim());
    }
    final enriched = _mergeProfile(
      AuthSessionModel.fromEntity(session),
      entity,
    );
    await _local.saveSession(enriched);
    await _local.saveCachedProfile(profile);
    await _onProfileSynced?.call(entity);
    return entity;
  }

  @override
  Future<void> completeOnboardingOnServer() async {
    final token = await _coordinator?.getValidAccessToken();
    final session = await getStoredSession();
    if (token == null || session == null || !session.isValid) {
      throw AuthApiException('Oturum bulunamadı.');
    }
    final profile = await _remote.completeOnboarding(token);
    final entity = profile.toEntity();
    final enriched = _mergeProfile(
      AuthSessionModel.fromEntity(session),
      entity,
    );
    await _local.saveSession(enriched);
    await _local.saveCachedProfile(profile);
    await _onProfileSynced?.call(entity);
  }

  @override
  Future<void> deleteAccount() async {
    final token = await _coordinator?.getValidAccessToken();
    if (token == null || token.isEmpty) {
      throw AuthApiException('Oturum bulunamadı. Lütfen tekrar giriş yapın.');
    }
    await _remote.deleteAccount(token);
    await clearSession();
  }

  @override
  Future<void> logout() => clearSession();

  @override
  Future<void> clearSession() async {
    await _onLogout?.call();
    await _local.clearSession();
  }
}
