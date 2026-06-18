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
  bool _sessionExpiredDialogActive = false;

  void configure({
    required GlobalKey<NavigatorState> navigatorKey,
    required Future<void> Function() onForceLogout,
  }) {
    _navigatorKey = navigatorKey;
    _onForceLogout = onForceLogout;
  }

  void handleIfNeeded(AuthApiException error) {
    if (!error.requiresReLogin || _sessionExpiredDialogActive) return;
    _sessionExpiredDialogActive = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_showDialog(error.message));
    });
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
        onLoginPressed: () {
          final logout = _onForceLogout;
          if (logout != null) {
            unawaited(logout());
          }
        },
      );
    } finally {
      _sessionExpiredDialogActive = false;
    }
  }
}
