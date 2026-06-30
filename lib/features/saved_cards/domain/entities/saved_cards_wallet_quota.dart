import 'wallet_plan_tier.dart';
import '../saved_cards_wallet_limits.dart';

/// Kullanıcının kayıtlı kart kotası özeti.
class SavedCardsWalletQuota {
  const SavedCardsWalletQuota({
    required this.tier,
    required this.usedCount,
    required this.maxCards,
    this.businessCardCount = 0,
    this.maxBusinessCards = SavedCardsWalletLimits.freeMaxOwnBusinessCards,
    this.canAddBusinessCard = true,
    this.canAddManualSavedCard = true,
    this.eventGroupCount = 0,
    this.maxEventGroups = SavedCardsWalletLimits.freeMaxEventGroups,
    this.canAddEventGroup = true,
  });

  /// Servis yanıtı gelene kadar ücretsiz plan varsayılanı (15 kart).
  factory SavedCardsWalletQuota.freeDefault({
    int usedCount = 0,
    int eventGroupCount = 0,
    int businessCardCount = 0,
  }) {
    return SavedCardsWalletQuota(
      tier: WalletPlanTier.free,
      usedCount: usedCount,
      maxCards: SavedCardsWalletLimits.freeMaxCards,
      businessCardCount: businessCardCount,
      eventGroupCount: eventGroupCount,
    );
  }

  SavedCardsWalletQuota withCounts({
    int? usedCount,
    int? eventGroupCount,
    int? businessCardCount,
  }) {
    return SavedCardsWalletQuota(
      tier: tier,
      usedCount: usedCount ?? this.usedCount,
      maxCards: maxCards,
      businessCardCount: businessCardCount ?? this.businessCardCount,
      maxBusinessCards: maxBusinessCards,
      canAddBusinessCard: canAddBusinessCard,
      canAddManualSavedCard: canAddManualSavedCard,
      eventGroupCount: eventGroupCount ?? this.eventGroupCount,
      maxEventGroups: maxEventGroups,
      canAddEventGroup: canAddEventGroup,
    );
  }

  final WalletPlanTier tier;
  final int usedCount;
  final int maxCards;
  final int businessCardCount;
  final int maxBusinessCards;
  final bool canAddBusinessCard;
  final bool canAddManualSavedCard;
  final int eventGroupCount;
  final int maxEventGroups;
  final bool canAddEventGroup;

  bool get hasUnlimitedWallet => isPremium;

  int get remaining =>
      hasUnlimitedWallet ? 0 : (maxCards - usedCount).clamp(0, maxCards);

  bool get canAddMore =>
      hasUnlimitedWallet || (maxCards > 0 && usedCount < maxCards);

  bool get isNearLimit {
    if (hasUnlimitedWallet || maxCards <= 0) return false;
    return usedCount >= (maxCards * 0.85).ceil();
  }

  double get usageFraction => hasUnlimitedWallet || maxCards <= 0
      ? 0
      : (usedCount / maxCards).clamp(0.0, 1.0);

  bool get isPremium => tier == WalletPlanTier.premium;

  bool get hasUnlimitedEventGroups => isPremium;

  String get walletCapacityLabel =>
      hasUnlimitedWallet ? 'Sınırsız' : '$maxCards';

  String get remainingSlotsLabel =>
      hasUnlimitedWallet ? 'Sınırsız' : '$remaining boş slot';

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is SavedCardsWalletQuota &&
            other.tier == tier &&
            other.usedCount == usedCount &&
            other.maxCards == maxCards &&
            other.businessCardCount == businessCardCount &&
            other.maxBusinessCards == maxBusinessCards &&
            other.canAddBusinessCard == canAddBusinessCard &&
            other.canAddManualSavedCard == canAddManualSavedCard &&
            other.eventGroupCount == eventGroupCount &&
            other.maxEventGroups == maxEventGroups &&
            other.canAddEventGroup == canAddEventGroup;
  }

  @override
  int get hashCode => Object.hash(
        tier,
        usedCount,
        maxCards,
        businessCardCount,
        maxBusinessCards,
        canAddBusinessCard,
        canAddManualSavedCard,
        eventGroupCount,
        maxEventGroups,
        canAddEventGroup,
      );
}
