/// Cardence .NET backend base URL.
class ApiConfig {
  ApiConfig._();

  /// Aktif API sunucusu.
  static const String productionBaseUrl = 'https://cardenceapi.app';

  /// Yerel geliştirme override:
  /// `flutter run --dart-define=API_BASE_URL=http://localhost:5241`
  static const String _envOverride = String.fromEnvironment('API_BASE_URL');

  static String get baseUrl {
    if (_envOverride.isNotEmpty) {
      return _envOverride;
    }
    return productionBaseUrl;
  }
}
