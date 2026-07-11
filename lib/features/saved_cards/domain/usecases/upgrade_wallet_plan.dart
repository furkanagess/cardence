import '../../../subscriptions/domain/entities/wallet_paywall_result.dart';
import '../../../subscriptions/domain/repositories/subscription_repository.dart';
import '../../../subscriptions/domain/usecases/finalize_premium_wallet_activation.dart';
import '../../../plans/domain/entities/plan_tier.dart';
import '../../../plans/domain/usecases/get_plan_entitlements.dart';

/// RevenueCat paywall üzerinden satın alma ve sunucu kotası senkronizasyonu.
class UpgradeWalletPlan {
  const UpgradeWalletPlan(
    this._subscriptionRepository,
    this._getPlanEntitlements,
    this._finalizePremiumWalletActivation,
  );

  final SubscriptionRepository _subscriptionRepository;
  final GetPlanEntitlements _getPlanEntitlements;
  final FinalizePremiumWalletActivation _finalizePremiumWalletActivation;

  Future<bool> call({bool onlyIfNeeded = false}) async {
    final result = await _subscriptionRepository.presentWalletPaywall(
      onlyIfNeeded: onlyIfNeeded,
    );

    switch (result) {
      case WalletPaywallResult.cancelled:
      case WalletPaywallResult.error:
        return false;
      case WalletPaywallResult.notPresented:
        if (!onlyIfNeeded &&
            await _subscriptionRepository.hasPremiumWalletEntitlement()) {
          await _tryFinalize();
          return true;
        }
        return false;
      case WalletPaywallResult.purchased:
      case WalletPaywallResult.restored:
        break;
    }

    if (!await _subscriptionRepository.hasPremiumWalletEntitlement()) {
      return false;
    }

    await _waitForBackendPremiumEntitlement();
    await _tryFinalize();
    return true;
  }

  Future<void> _tryFinalize() async {
    try {
      await _finalizePremiumWalletActivation();
    } catch (_) {
      // Me veya kota senkronu gecikse bile satın alma tamamlandı sayılır.
    }
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
