/// Cardence uygulamasında desteklenen 4 giriş yöntemi.
enum AuthProvider {
  /// Google ile giriş (Firebase Auth + google_sign_in)
  google,

  /// Apple ile giriş (Firebase Auth + sign_in_with_apple)
  apple,

  /// Telefon numarası ile giriş (Firebase Auth Phone)
  phone,

  /// LinkedIn ile giriş (LinkedIn OAuth + Firestore kullanıcı eşlemesi)
  linkedin,
}

/// Auth provider görünen adları ve provider ID'leri.
class AuthConstants {
  AuthConstants._();

  /// Firebase Auth providerId değerleri (UserInfo.providerId ile eşleşir).
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

  /// Firebase Auth providerId'den AuthProvider'a dönüşüm.
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
