import '../../domain/entities/saved_cards_wallet_quota.dart';
import '../../domain/entities/wallet_plan_tier.dart';
import '../../domain/saved_cards_wallet_limits.dart';

class WalletQuotaModel {
  const WalletQuotaModel({
    required this.tier,
    required this.usedCount,
    required this.maxCards,
    required this.businessCardCount,
    required this.maxBusinessCards,
    required this.canAddBusinessCard,
    required this.canAddManualSavedCard,
    required this.eventGroupCount,
    required this.maxEventGroups,
    required this.canAddEventGroup,
  });

  final String tier;
  final int usedCount;
  final int maxCards;
  final int businessCardCount;
  final int maxBusinessCards;
  final bool canAddBusinessCard;
  final bool canAddManualSavedCard;
  final int eventGroupCount;
  final int maxEventGroups;
  final bool canAddEventGroup;

  factory WalletQuotaModel.fromJson(Map<String, dynamic> json) {
    return WalletQuotaModel(
      tier: (json['tier'] ?? json['Tier'] ?? 'free').toString(),
      usedCount: _readInt(json['usedCount'] ?? json['UsedCount']),
      maxCards: _readInt(json['maxCards'] ?? json['MaxCards']),
      businessCardCount: _readInt(
        json['businessCardCount'] ?? json['BusinessCardCount'],
      ),
      maxBusinessCards: _readInt(
        json['maxBusinessCards'] ?? json['MaxBusinessCards'],
        fallback: SavedCardsWalletLimits.freeMaxOwnBusinessCards,
      ),
      canAddBusinessCard: _readBool(
        json['canAddBusinessCard'] ?? json['CanAddBusinessCard'],
        fallback: true,
      ),
      canAddManualSavedCard: _readBool(
        json['canAddManualSavedCard'] ?? json['CanAddManualSavedCard'],
      ),
      eventGroupCount: _readInt(
        json['eventGroupCount'] ?? json['EventGroupCount'],
      ),
      maxEventGroups: _readInt(
        json['maxEventGroups'] ?? json['MaxEventGroups'],
        fallback: SavedCardsWalletLimits.freeMaxEventGroups,
      ),
      canAddEventGroup: _readBool(
        json['canAddEventGroup'] ?? json['CanAddEventGroup'],
        fallback: true,
      ),
    );
  }

  static int _readInt(dynamic value, {int fallback = 0}) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? fallback;
    return fallback;
  }

  static bool _readBool(dynamic value, {bool fallback = false}) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      final normalized = value.trim().toLowerCase();
      if (normalized == 'true') return true;
      if (normalized == 'false') return false;
    }
    return fallback;
  }

  SavedCardsWalletQuota toEntity() {
    final normalizedTier = tier.trim().toLowerCase();
    final isPremium = normalizedTier == WalletPlanTier.premium.name;
    return SavedCardsWalletQuota(
      tier: isPremium ? WalletPlanTier.premium : WalletPlanTier.free,
      usedCount: usedCount,
      maxCards: maxCards,
      businessCardCount: businessCardCount,
      maxBusinessCards: maxBusinessCards,
      canAddBusinessCard: canAddBusinessCard,
      canAddManualSavedCard: canAddManualSavedCard ||
          isPremium,
      eventGroupCount: eventGroupCount,
      maxEventGroups: maxEventGroups,
      canAddEventGroup: canAddEventGroup || isPremium,
    );
  }
}
