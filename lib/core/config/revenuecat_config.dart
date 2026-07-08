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

  /// RevenueCat dashboard paywall kimliği (offering'e bağlı template).
  static const walletPaywallIdentifier = 'cardence-pro-discount';

  /// Cardence Pro offering kimliği (RevenueCat dashboard).
  static const walletOfferingIdentifier = 'cardencepro';

  /// Placement kullanılmıyor; offering doğrudan hedeflenir.
  static const String? walletPlacementIdentifier = null;

  /// Mağaza ürün kimliği (Test Store / App Store Connect).
  /// RevenueCat → Products → `cardencepro`
  static const walletStoreProductIdentifier = 'cardencepro';

  /// Offering içindeki package kimliği (offering → Packages sekmesi).
  /// Ürün kimliğinden farklı olabilir; örn. `$rc_monthly` veya `cardencepro`.
  static const walletPackageIdentifier = 'cardencepro';
}
