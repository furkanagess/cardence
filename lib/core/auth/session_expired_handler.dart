import 'dart:async';

import 'package:flutter/material.dart';

import '../network/auth_api_exception.dart';
import '../widgets/molecules/session_expired_dialog.dart';

/// Oturum süresi dolduğunda zorunlu çıkış diyaloğu.
class SessionExpiredHandler {
  SessionExpiredHandler._();

  static final SessionExpiredHandler instance = SessionExpiredHandler._();

  GlobalKey<NavigatorState>? _navigatorKey;
  Future<void> Function()? _onForceLogout;
  Future<bool> Function()? _hasStoredSession;
  bool _sessionExpiredDialogActive = false;

  void configure({
    required GlobalKey<NavigatorState> navigatorKey,
    required Future<void> Function() onForceLogout,
    Future<bool> Function()? hasStoredSession,
  }) {
    _navigatorKey = navigatorKey;
    _onForceLogout = onForceLogout;
    _hasStoredSession = hasStoredSession;
  }

  void handleIfNeeded(
    AuthApiException error, {
    bool trustCallerHadSession = false,
  }) {
    if (!error.requiresReLogin || _sessionExpiredDialogActive) return;
    _sessionExpiredDialogActive = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(
        _maybeShowDialog(
          error.message,
          skipSessionCheck: trustCallerHadSession,
        ),
      );
    });
  }

  Future<void> _maybeShowDialog(
    String message, {
    bool skipSessionCheck = false,
  }) async {
    if (!skipSessionCheck) {
      final checker = _hasStoredSession;
      if (checker != null) {
        try {
          final hasSession = await checker();
          if (!hasSession) {
            _sessionExpiredDialogActive = false;
            return;
          }
        } catch (_) {
          _sessionExpiredDialogActive = false;
          return;
        }
      }
    }

    await _showDialog(message);
  }

  Future<void> _showDialog(String message) async {
    final context = _navigatorKey?.currentContext;
    if (context == null || !context.mounted) {
      _sessionExpiredDialogActive = false;
      return;
    }
    try {
      await SessionExpiredDialog.show(
        context,
        message: message,
        onLoginPressed: () async {
          final logout = _onForceLogout;
          if (logout != null) {
            await logout();
          }
        },
      );
    } finally {
      _sessionExpiredDialogActive = false;
    }
  }
}
