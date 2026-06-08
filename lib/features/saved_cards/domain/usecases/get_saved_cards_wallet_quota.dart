import '../entities/saved_cards_wallet_quota.dart';
import '../repositories/saved_card_repository.dart';

class GetSavedCardsWalletQuota {
  const GetSavedCardsWalletQuota(this._cardRepository);

  final SavedCardRepository _cardRepository;

  Future<SavedCardsWalletQuota> call() => _cardRepository.getWalletQuota();
}
