/// RevenueCat yapılandırması.
///
/// Dashboard'da `premium_wallet` entitlement kimliği tanımlı olmalıdır.
class RevenueCatConfig {
  RevenueCatConfig._();

  static const apiKey = 'test_mAIxZapqCdeWRwUtwXUNmNoJPoS';
  static const premiumEntitlementId = 'premium_wallet';

  /// Current offering içindeki paket kimliği (RevenueCat dashboard).
  /// Örnek: \$rc_monthly, \$rc_annual veya custom package id.
  static const walletPackageIdentifier = r'$rc_monthly';
}
