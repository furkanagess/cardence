import '../entities/wallet_paywall_result.dart';

abstract class SubscriptionRepository {
  Future<void> configure();

  Future<void> identifyUser(String userId);

  Future<void> logoutUser();

  Future<bool> purchaseWalletPremium();

  Future<WalletPaywallResult> presentWalletPaywall({
    bool onlyIfNeeded = false,
    bool? useDarkAppearance,
  });

  Future<bool> restorePurchases();

  Future<bool> hasPremiumWalletEntitlement();

  /// RevenueCat entitlement değişince (satın alma, yenileme, süre bitimi) tetiklenir.
  void registerEntitlementChangeHandler(Future<void> Function()? handler);
}
