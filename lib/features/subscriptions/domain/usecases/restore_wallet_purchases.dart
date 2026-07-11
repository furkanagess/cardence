import '../../../plans/domain/entities/plan_tier.dart';
import '../../../plans/domain/usecases/get_plan_entitlements.dart';
import 'finalize_premium_wallet_activation.dart';
import '../repositories/subscription_repository.dart';

class RestoreWalletPurchases {
  const RestoreWalletPurchases(
    this._subscriptionRepository,
    this._getPlanEntitlements,
    this._finalizePremiumWalletActivation,
  );

  final SubscriptionRepository _subscriptionRepository;
  final GetPlanEntitlements _getPlanEntitlements;
  final FinalizePremiumWalletActivation _finalizePremiumWalletActivation;

  Future<bool> call() async {
    final restored = await _subscriptionRepository.restorePurchases();
    if (!restored) return false;

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
      // Geri yükleme tamamlandı; sunucu senkronu gecikse bile devam et.
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
