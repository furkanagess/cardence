/// Cardence uygulamasında desteklenen giriş yöntemleri.
enum AuthProvider {
  /// Google ile giriş (native SDK + Cardence API JWT)
  google,

  /// Apple ile giriş (Sign in with Apple + Cardence API JWT)
  apple,

  /// Telefon numarası ile giriş
  phone,

  /// LinkedIn ile giriş (OAuth + Cardence API JWT)
  linkedin,
}

/// Auth provider görünen adları ve provider ID'leri.
class AuthConstants {
  AuthConstants._();

  /// Backend `user_auth_providers.provider_id` değerleri.
  static const String providerIdGoogle = 'google.com';
  static const String providerIdApple = 'apple.com';
  static const String providerIdPhone = 'phone';
  static const String providerIdLinkedIn = 'linkedin.com';

  static String displayName(AuthProvider provider) {
    switch (provider) {
      case AuthProvider.google:
        return 'Google';
      case AuthProvider.apple:
        return 'Apple';
      case AuthProvider.phone:
        return 'Telefon';
      case AuthProvider.linkedin:
        return 'LinkedIn';
    }
  }

  /// Provider ID'den AuthProvider'a dönüşüm.
  static AuthProvider? fromProviderId(String? providerId) {
    if (providerId == null) return null;
    switch (providerId) {
      case providerIdGoogle:
        return AuthProvider.google;
      case providerIdApple:
        return AuthProvider.apple;
      case providerIdPhone:
        return AuthProvider.phone;
      case providerIdLinkedIn:
        return AuthProvider.linkedin;
      default:
        return null;
    }
  }
}
