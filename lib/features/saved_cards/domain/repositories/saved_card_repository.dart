import '../entities/saved_card.dart';
import '../entities/saved_cards_wallet_quota.dart';

abstract class SavedCardRepository {
  Future<List<SavedCard>> getSavedCards();
  /// cardId ile business_cards kaydından güncel kartvizit bilgisini getirir.
  Future<SavedCard?> fetchPublicCardByCardId(String cardId);
  Future<SavedCard> addCard(SavedCard card);
  Future<void> saveCard(SavedCard card);
  Future<void> deleteCard(String cardId);
  Future<SavedCardsWalletQuota> getWalletQuota();
  Future<void> syncWalletPremium();
  Future<void> cacheFromProfile(List<SavedCard> cards);
}
