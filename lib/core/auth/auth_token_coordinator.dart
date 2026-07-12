import 'dart:async';

import 'package:dio/dio.dart';

import '../../features/auth/data/datasources/auth_local_datasource.dart';
import '../../features/auth/data/models/auth_session_model.dart';
import '../network/api_config.dart';
import '../network/api_response_parser.dart';
import '../network/auth_api_exception.dart';
import 'refresh_session_outcome.dart';
import 'session_expired_handler.dart';

/// Access / refresh token yaşam döngüsünü yönetir.
class AuthTokenCoordinator {
  AuthTokenCoordinator({
    required AuthLocalDataSource local,
    Future<void> Function()? onSessionCleared,
  })  : _local = local,
        _onSessionCleared = onSessionCleared;

  static AuthTokenCoordinator? instance;

  static void install(AuthTokenCoordinator coordinator) {
    instance = coordinator;
  }

  final AuthLocalDataSource _local;
  final Future<void> Function()? _onSessionCleared;
  final Dio _refreshDio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 8),
      receiveTimeout: const Duration(seconds: 8),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  Completer<RefreshSessionOutcome>? _refreshCompleter;
  bool _sessionInvalid = false;

  void resetAfterLogin() {
    _sessionInvalid = false;
  }

  Future<String?> getValidAccessToken({bool refreshIfStale = true}) async {
    if (_sessionInvalid) return null;

    final session = await _local.getSession();
    if (session == null) return null;

    final hasRefreshToken = session.refreshToken?.isNotEmpty ?? false;
    if (session.accessToken.isEmpty) {
      if (!hasRefreshToken) return null;
      final outcome = await refreshSession();
      if (!outcome.refreshed) return null;
      final updated = await _local.getSession();
      return updated?.accessToken;
    }

    if (!refreshIfStale || !session.isAccessTokenStale) {
      return session.accessToken;
    }

    final outcome = await refreshSession();
    if (!outcome.refreshed) {
      return session.accessToken.isNotEmpty ? session.accessToken : null;
    }

    final updated = await _local.getSession();
    return updated?.accessToken;
  }

  Future<RefreshSessionOutcome> refreshSession() async {
    if (_sessionInvalid) {
      return const RefreshSessionOutcome.invalidToken();
    }

    if (_refreshCompleter != null) {
      return _refreshCompleter!.future;
    }

    final completer = Completer<RefreshSessionOutcome>();
    _refreshCompleter = completer;

    try {
      final session = await _local.getSession();
      final refreshToken = session?.refreshToken;
      if (session == null ||
          refreshToken == null ||
          refreshToken.isEmpty) {
        const outcome = RefreshSessionOutcome.invalidToken();
        completer.complete(outcome);
        return outcome;
      }

      final refreshed = await _requestRefresh(refreshToken);
      if (refreshed == null) {
        const outcome = RefreshSessionOutcome.failed();
        completer.complete(outcome);
        return outcome;
      }

      final merged = AuthSessionModel(
        accessToken: refreshed.accessToken,
        refreshToken: refreshed.refreshToken ?? refreshToken,
        userId: refreshed.userId.isNotEmpty ? refreshed.userId : session.userId,
        expiresIn: refreshed.expiresIn > 0
            ? refreshed.expiresIn
            : session.expiresIn,
        email: refreshed.email ?? session.email,
        phone: refreshed.phone ?? session.phone,
        displayName: refreshed.displayName ?? session.displayName,
      ).withComputedExpiry();

      await _local.saveSession(merged);
      _sessionInvalid = false;
      const outcome = RefreshSessionOutcome.refreshed();
      completer.complete(outcome);
      return outcome;
    } on AuthApiException catch (error) {
      final outcome = _outcomeFromRefreshError(error);
      completer.complete(outcome);
      return outcome;
    } on DioException catch (error) {
      final outcome = _outcomeFromRefreshError(
        ApiResponseParser.fromDioException(error, 'Oturum yenilenemedi.'),
      );
      completer.complete(outcome);
      return outcome;
    } catch (_) {
      const outcome = RefreshSessionOutcome.failed();
      completer.complete(outcome);
      return outcome;
    } finally {
      _refreshCompleter = null;
    }
  }

  Future<AuthSessionModel?> _requestRefresh(String refreshToken) async {
    final response = await _refreshDio.post<dynamic>(
      '${ApiConfig.baseUrl}/RefreshAuthentication',
      data: {'refreshToken': refreshToken},
    );

    final json = ApiResponseParser.parseEnvelope(
      response,
      'Oturum yenilenemedi.',
    );
    final entity = ApiResponseParser.extractEntity(json);
    if (entity == null) return null;

    final session = AuthSessionModel.fromJson(entity);
    if (session.accessToken.isEmpty || session.userId.isEmpty) {
      return null;
    }
    return session;
  }

  RefreshSessionOutcome _outcomeFromRefreshError(AuthApiException error) {
    if (error.errorCode == 'InvalidRefreshToken' || error.code == 1006) {
      return const RefreshSessionOutcome.invalidToken();
    }
    if (error.isUnauthorized) {
      return const RefreshSessionOutcome.invalidToken();
    }
    if (error.isNetworkError) {
      return const RefreshSessionOutcome.failed();
    }
    return const RefreshSessionOutcome.failed();
  }

  Future<bool> hasStoredSession() async {
    if (_sessionInvalid) return false;

    final session = await _local.getSession();
    if (session == null) return false;

    final hasAccessToken = session.accessToken.isNotEmpty;
    final hasRefreshToken = session.refreshToken?.isNotEmpty ?? false;
    return hasAccessToken || hasRefreshToken;
  }

  Future<void> invalidateSession({bool showDialog = true}) async {
    if (_sessionInvalid && !showDialog) return;

    final hadSession = await hasStoredSession();

    if (showDialog && hadSession) {
      SessionExpiredHandler.instance.handleIfNeeded(
        AuthApiException(
          'Oturum süresi doldu. Lütfen tekrar giriş yapın.',
          statusCode: 401,
        ),
        trustCallerHadSession: true,
      );
    }

    _sessionInvalid = true;
    await _onSessionCleared?.call();
  }
}
