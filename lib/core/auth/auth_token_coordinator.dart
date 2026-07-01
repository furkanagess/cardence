import 'dart:async';

import 'package:dio/dio.dart';

import '../../features/auth/data/datasources/auth_local_datasource.dart';
import '../../features/auth/data/models/auth_session_model.dart';
import '../network/api_config.dart';
import '../network/api_response_parser.dart';
import '../network/auth_api_exception.dart';
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

  Completer<bool>? _refreshCompleter;
  bool _sessionInvalid = false;

  void resetAfterLogin() {
    _sessionInvalid = false;
  }

  Future<String?> getValidAccessToken({bool refreshIfStale = true}) async {
    if (_sessionInvalid) return null;

    final session = await _local.getSession();
    if (session == null || session.accessToken.isEmpty) return null;

    if (!refreshIfStale || !session.isAccessTokenStale) {
      return session.accessToken;
    }

    final refreshed = await refreshSession();
    if (!refreshed) {
      return session.accessToken.isNotEmpty ? session.accessToken : null;
    }

    final updated = await _local.getSession();
    return updated?.accessToken;
  }

  Future<bool> refreshSession() async {
    if (_sessionInvalid) return false;

    if (_refreshCompleter != null) {
      return _refreshCompleter!.future;
    }

    final completer = Completer<bool>();
    _refreshCompleter = completer;

    try {
      final session = await _local.getSession();
      final refreshToken = session?.refreshToken;
      if (session == null ||
          refreshToken == null ||
          refreshToken.isEmpty) {
        completer.complete(false);
        return false;
      }

      final refreshed = await _requestRefresh(refreshToken);
      if (refreshed == null) {
        completer.complete(false);
        return false;
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
      completer.complete(true);
      return true;
    } catch (_) {
      completer.complete(false);
      return false;
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

  Future<void> invalidateSession({bool showDialog = true}) async {
    if (_sessionInvalid && !showDialog) return;
    _sessionInvalid = true;
    await _onSessionCleared?.call();
    if (showDialog) {
      SessionExpiredHandler.instance.handleIfNeeded(
        AuthApiException(
          'Oturum süresi doldu. Lütfen tekrar giriş yapın.',
          statusCode: 401,
        ),
      );
    }
  }
}
