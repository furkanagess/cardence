import '../entities/wallet_plan_tier.dart';

abstract class WalletEntitlementRepository {
  Future<WalletPlanTier> getPlanTier();

  Future<void> setPlanTier(WalletPlanTier tier);
}
