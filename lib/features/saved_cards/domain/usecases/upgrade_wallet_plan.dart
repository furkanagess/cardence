import '../../../subscriptions/domain/entities/wallet_paywall_result.dart';
import '../../../subscriptions/domain/repositories/subscription_repository.dart';
import '../repositories/saved_card_repository.dart';

/// RevenueCat paywall üzerinden satın alma ve sunucu kotası senkronizasyonu.
class UpgradeWalletPlan {
  const UpgradeWalletPlan(
    this._subscriptionRepository,
    this._savedCardRepository,
  );

  final SubscriptionRepository _subscriptionRepository;
  final SavedCardRepository _savedCardRepository;

  Future<bool> call() async {
    final result = await _subscriptionRepository.presentWalletPaywall();
    switch (result) {
      case WalletPaywallResult.purchased:
      case WalletPaywallResult.restored:
      case WalletPaywallResult.notPresented:
        break;
      case WalletPaywallResult.cancelled:
      case WalletPaywallResult.error:
        return false;
    }

    if (!await _subscriptionRepository.hasPremiumWalletEntitlement()) {
      return false;
    }

    await _savedCardRepository.syncWalletPremium();
    return true;
  }
}
