import '../../../subscriptions/domain/entities/wallet_paywall_result.dart';
import '../../../subscriptions/domain/repositories/subscription_repository.dart';
import '../../../plans/domain/entities/plan_tier.dart';
import '../../../plans/domain/usecases/get_plan_entitlements.dart';

/// RevenueCat paywall üzerinden satın alma ve sunucu kotası senkronizasyonu.
class UpgradeWalletPlan {
  const UpgradeWalletPlan(
    this._subscriptionRepository,
    this._getPlanEntitlements,
  );

  final SubscriptionRepository _subscriptionRepository;
  final GetPlanEntitlements _getPlanEntitlements;

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

    return _waitForBackendPremiumEntitlement();
  }

  Future<bool> _waitForBackendPremiumEntitlement() async {
    for (var attempt = 0; attempt < 5; attempt++) {
      final entitlements = await _getPlanEntitlements();
      if (entitlements.tier == PlanTier.premium ||
          entitlements.tier == PlanTier.business ||
          entitlements.tier == PlanTier.enterprise) {
        return true;
      }

      if (attempt < 4) {
        await Future<void>.delayed(const Duration(seconds: 1));
      }
    }

    return false;
  }
}
