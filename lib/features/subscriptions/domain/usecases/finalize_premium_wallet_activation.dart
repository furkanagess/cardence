import '../../../saved_cards/domain/repositories/saved_card_repository.dart';
import '../../../saved_cards/domain/entities/saved_cards_wallet_quota.dart';

/// Sunucu tarafında wallet tier ve `isOwnerPremium` bayraklarını premium yapar.
class FinalizePremiumWalletActivation {
  const FinalizePremiumWalletActivation(this._savedCardRepository);

  final SavedCardRepository _savedCardRepository;

  /// [requirePremium]: true ise sunucu hâlâ free dönerse hata fırlatır.
  /// Entitlement listener gibi arka plan sync'lerinde false kullan.
  Future<SavedCardsWalletQuota> call({bool requirePremium = true}) async {
    final quota = await _savedCardRepository.syncWalletPremium();
    if (requirePremium && !quota.isPremium) {
      throw StateError(
        'UpgradeWalletPlan premium yazmadı (tier=${quota.tier.name}).',
      );
    }
    return quota;
  }
}
