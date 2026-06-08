import 'package:flutter/foundation.dart';

/// Uygulama ortamı ve geliştirici araçları (Chuck) bayrakları.
class AppEnv {
  AppEnv._();

  /// Prod build'de Chuck'ı zorla açmak için (varsayılan kapalı).
  static const bool enableChuckInProd = false;

  static const String _envDefine = String.fromEnvironment(
    'ENV',
    defaultValue: 'dev',
  );

  static bool _debugMode = _resolveInitialDebugMode();

  static bool _resolveInitialDebugMode() {
    if (_envDefine == 'prod') return false;
    if (_envDefine == 'dev') return true;
    return kDebugMode;
  }

  /// Runtime API ortamı (DEV seçimi). Login ortam değiştirici ile güncellenebilir.
  static bool get kDebugMode => _debugMode;

  static void setDebugMode(bool value) {
    _debugMode = value;
  }

  /// Chuck HTTP inspector aktif mi?
  static bool get isChuckEnabled => kDebugMode || enableChuckInProd;
}
