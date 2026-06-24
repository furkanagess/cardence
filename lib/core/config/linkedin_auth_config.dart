import '../network/api_config.dart';

/// LinkedIn OAuth (Sign In with LinkedIn) yapılandırması.
///
/// Client secret yalnızca backend'de tutulur; bu dosyaya eklenmez.
class LinkedInAuthConfig {
  LinkedInAuthConfig._();

  static const String clientId = '77zpy3yc04qs2c';

  /// OAuth redirect URI — LinkedIn yalnızca HTTP/HTTPS kabul eder.
  /// Developer Portal → Auth → Redirect URLs ile birebir eşleşmeli.
  static String get redirectUri => '${ApiConfig.baseUrl}/auth/linkedin/callback';
}
