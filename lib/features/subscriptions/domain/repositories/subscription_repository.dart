import '../entities/wallet_paywall_result.dart';

abstract class SubscriptionRepository {
  Future<void> configure();

  Future<void> identifyUser(String userId);

  Future<void> logoutUser();

  Future<bool> purchaseWalletPremium();

  Future<WalletPaywallResult> presentWalletPaywall({
    bool onlyIfNeeded = false,
    bool? useDarkAppearance,
    String? preferredLocale,
  });

  /// Paywall / Customer Center dilini uygulama diline göre ayarlar.
  Future<void> setPreferredLocale(String? locale);

  Future<bool> restorePurchases();

  Future<bool> hasPremiumWalletEntitlement();

  /// RevenueCat entitlement değişince (satın alma, yenileme, süre bitimi) tetiklenir.
  void registerEntitlementChangeHandler(Future<void> Function()? handler);
}
