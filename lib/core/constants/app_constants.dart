/// Uygulama genel sabitleri.
class AppConstants {
  AppConstants._();

  static const String appName = 'Cardence';
  /// "Cardence: [appTagline]" – subtitle; total with "Cardence: " ≤ 30 chars.
  static const String appTagline = 'Share & Connect';
  static const String appVersion = '1.0.0';
  static const int maxVisibleFields = 5;
  /// Kart ön yüzünde en fazla gösterilecek alan sayısı.
  static const int maxFrontCardFields = 3;
  /// Kart arka yüzünde en fazla gösterilecek alan sayısı.
  static const int maxBackCardFields = 3;

  /// Onboarding sayfa sayısı.
  static const int onboardingPageCount = 3;
}
