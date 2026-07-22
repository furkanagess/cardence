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

    // Önce sunucuyu yükselt, sonra entitlement'ın yansımasını bekle.
    await _tryFinalize();
    await _waitForBackendPremiumEntitlement();
    return true;
  }

  Future<void> _tryFinalize() async {
    for (var attempt = 0; attempt < 3; attempt++) {
      try {
        await _finalizePremiumWalletActivation();
        return;
      } catch (_) {
        if (attempt < 2) {
          await Future<void>.delayed(const Duration(seconds: 1));
        }
      }
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
