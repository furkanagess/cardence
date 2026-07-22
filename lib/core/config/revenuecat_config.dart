import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';

/// RevenueCat yapılandırması.
///
/// Dashboard entitlement kimlikleri: `cardence-pro`, `cardence-pro-discount`.
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

  /// Birincil entitlement (paywall `presentPaywallIfNeeded` için).
  static const premiumEntitlementId = 'cardence-pro';

  /// İndirimli / alternatif premium entitlement.
  static const premiumDiscountEntitlementId = 'cardence-pro-discount';

  /// Aktif premium sayılan tüm entitlement kimlikleri.
  static const Set<String> premiumEntitlementIds = {
    premiumEntitlementId,
    premiumDiscountEntitlementId,
  };

  static bool isPremiumEntitlementId(String id) =>
      premiumEntitlementIds.contains(id);

  /// RevenueCat dashboard paywall kimliği (offering'e bağlı template).
  static const walletPaywallIdentifier = 'cardence-monthly';

  /// Cardence Pro offering kimliği (RevenueCat dashboard).
  static const walletOfferingIdentifier = 'cardencepro';

  /// Placement ile hedeflenen paywall (RevenueCat Targeting).
  static const walletPlacementIdentifier = 'cardence-monthly';

  /// Mağaza ürün kimliği (Test Store / App Store Connect).
  /// RevenueCat → Products → `cardencepro`
  static const walletStoreProductIdentifier = 'cardencepro';

  /// Offering içindeki package kimliği (offering → Packages sekmesi).
  /// Ürün kimliğinden farklı olabilir; örn. `$rc_monthly` veya `cardencepro`.
  static const walletPackageIdentifier = 'cardencepro';
}
