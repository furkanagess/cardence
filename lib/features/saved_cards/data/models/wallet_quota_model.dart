import '../../domain/entities/saved_cards_wallet_quota.dart';
import '../../domain/entities/wallet_plan_tier.dart';

class WalletQuotaModel {
  const WalletQuotaModel({
    required this.tier,
    required this.usedCount,
    required this.maxCards,
  });

  final String tier;
  final int usedCount;
  final int maxCards;

  factory WalletQuotaModel.fromJson(Map<String, dynamic> json) {
    return WalletQuotaModel(
      tier: (json['tier'] ?? json['Tier'] ?? 'free').toString(),
      usedCount: _readInt(json['usedCount'] ?? json['UsedCount']),
      maxCards: _readInt(json['maxCards'] ?? json['MaxCards']),
    );
  }

  static int _readInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  SavedCardsWalletQuota toEntity() {
    final normalizedTier = tier.trim().toLowerCase();
    return SavedCardsWalletQuota(
      tier: normalizedTier == WalletPlanTier.premium.name
          ? WalletPlanTier.premium
          : WalletPlanTier.free,
      usedCount: usedCount,
      maxCards: maxCards,
    );
  }
}
