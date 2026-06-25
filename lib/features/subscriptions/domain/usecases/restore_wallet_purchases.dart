import '../../../plans/domain/entities/plan_tier.dart';
import '../../../plans/domain/usecases/get_plan_entitlements.dart';
import '../repositories/subscription_repository.dart';

class RestoreWalletPurchases {
  const RestoreWalletPurchases(
    this._subscriptionRepository,
    this._getPlanEntitlements,
  );

  final SubscriptionRepository _subscriptionRepository;
  final GetPlanEntitlements _getPlanEntitlements;

  Future<bool> call() async {
    final restored = await _subscriptionRepository.restorePurchases();
    if (!restored) return false;

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
