import '../entities/saved_cards_wallet_quota.dart';
import '../entities/wallet_plan_tier.dart';
import '../repositories/saved_card_repository.dart';
import '../repositories/wallet_entitlement_repository.dart';
import '../saved_cards_wallet_limits.dart';

class GetSavedCardsWalletQuota {
  const GetSavedCardsWalletQuota(
    this._cardRepository,
    this._walletRepository,
  );

  final SavedCardRepository _cardRepository;
  final WalletEntitlementRepository _walletRepository;

  Future<SavedCardsWalletQuota> call() async {
    final tier = await _walletRepository.getPlanTier();
    final cards = await _cardRepository.getSavedCards();
    final maxCards = tier == WalletPlanTier.premium
        ? SavedCardsWalletLimits.premiumMaxCards
        : SavedCardsWalletLimits.freeMaxCards;

    return SavedCardsWalletQuota(
      tier: tier,
      usedCount: cards.length,
      maxCards: maxCards,
    );
  }
}
