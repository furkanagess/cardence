import 'wallet_plan_tier.dart';

/// Kullanıcının kayıtlı kart kotası özeti.
class SavedCardsWalletQuota {
  const SavedCardsWalletQuota({
    required this.tier,
    required this.usedCount,
    required this.maxCards,
  });

  final WalletPlanTier tier;
  final int usedCount;
  final int maxCards;

  int get remaining => (maxCards - usedCount).clamp(0, maxCards);

  bool get canAddMore => usedCount < maxCards;

  bool get isNearLimit {
    if (maxCards <= 0) return false;
    return usedCount >= (maxCards * 0.85).ceil();
  }

  double get usageFraction =>
      maxCards == 0 ? 0 : (usedCount / maxCards).clamp(0.0, 1.0);

  bool get isPremium => tier == WalletPlanTier.premium;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is SavedCardsWalletQuota &&
            other.tier == tier &&
            other.usedCount == usedCount &&
            other.maxCards == maxCards;
  }

  @override
  int get hashCode => Object.hash(tier, usedCount, maxCards);
}
