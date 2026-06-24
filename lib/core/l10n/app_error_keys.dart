import 'package:flutter/material.dart';

/// BLoC/Cubit katmanında kullanılan hata anahtarları; UI'da [ApiErrorLocalizer] ile çevrilir.
abstract final class AppErrorKeys {
  static const connectionError = '__error_connection__';
}
