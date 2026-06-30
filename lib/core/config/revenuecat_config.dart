import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';

/// RevenueCat yapılandırması.
///
/// Dashboard'da `cardence-pro` entitlement kimliği tanımlı olmalıdır.
class RevenueCatConfig {
  RevenueCatConfig._();

  /// App Store (iOS) public API anahtarı.
  static const iosApiKey = 'appl_WMhOCMGAWTUAoDNINcHrPOmUPgM';

  /// Play Store (Android) public API anahtarı.
  static const androidApiKey = 'goog_ktCZtyNOflBEHPXvHhmHfihoBKt';

  /// Çalışılan platforma uygun RevenueCat API anahtarı.
  static String get apiKey {
    if (kIsWeb) return androidApiKey;
    if (Platform.isIOS || Platform.isMacOS) return iosApiKey;
    return androidApiKey;
  }

  static const premiumEntitlementId = 'cardence-pro';

  /// Current offering içindeki paket kimliği (RevenueCat dashboard).
  /// Örnek: \$rc_monthly, \$rc_annual veya custom package id.
  static const walletPackageIdentifier = r'$rc_monthly';
}
