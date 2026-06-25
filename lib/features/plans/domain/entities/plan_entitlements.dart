import 'plan_features.dart';
import 'plan_limits.dart';
import 'plan_tier.dart';

class PlanEntitlements {
  const PlanEntitlements({
    required this.tier,
    required this.features,
    required this.limits,
  });

  final PlanTier tier;
  final PlanFeatures features;
  final PlanLimits limits;

  bool get isPremiumOrHigher =>
      tier == PlanTier.premium ||
      tier == PlanTier.business ||
      tier == PlanTier.enterprise;
}
