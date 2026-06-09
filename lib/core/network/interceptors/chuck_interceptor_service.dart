import 'package:chuck_interceptor/chuck.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../config/app_env.dart';
import '../dio_client.dart';

/// Chuck (`chuck_interceptor`) facade — paket yalnızca bu dosyada import edilir.
class ChuckInterceptorService {
  ChuckInterceptorService._();

  static final ChuckInterceptorService instance = ChuckInterceptorService._();

  Chuck? _chuck;
  GlobalKey<NavigatorState>? _boundNavigatorKey;

  bool get isActive => _chuck != null && AppEnv.isChuckEnabled;

  GlobalKey<NavigatorState>? get navigatorKey =>
      _boundNavigatorKey ?? _chuck?.getNavigatorKey();

  Interceptor? get dioInterceptor => _chuck?.getDioInterceptor();

  /// Chuck instance hazırlar. [DioClient] oluşturulmadan önce çağrılmalı.
  void initialize({GlobalKey<NavigatorState>? navigatorKey}) {
    if (!AppEnv.isChuckEnabled) return;

    if (navigatorKey != null) {
      _boundNavigatorKey = navigatorKey;
    }

    if (_chuck != null) return;

    _chuck = Chuck(
      navigatorKey: _boundNavigatorKey,
      showNotification: false,
      showInspectorOnShake: true,
    );
  }

  /// Idempotent başlatma; [navigatorKey] bir kez bağlandıktan sonra saklanır.
  void ensureInitialized({GlobalKey<NavigatorState>? navigatorKey}) {
    if (!AppEnv.isChuckEnabled) return;
    initialize(navigatorKey: navigatorKey);
  }

  /// Runtime'da Chuck'ı kapatır. Ardından [DioClient.reset] çağrılır.
  void disable() {
    _chuck = null;
    DioClient.reset();
  }

  /// Inspector ekranını açar.
  void showInspector() {
    if (!AppEnv.isChuckEnabled) return;
    ensureInitialized(navigatorKey: _boundNavigatorKey);
    _chuck?.showInspector();
  }
}
