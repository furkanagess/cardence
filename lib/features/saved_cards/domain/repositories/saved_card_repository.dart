import '../entities/saved_card.dart';
import '../entities/saved_cards_wallet_quota.dart';
import '../entities/wallet_card_invitation.dart';

abstract class SavedCardRepository {
  Future<List<SavedCard>> getSavedCards();

  /// cardId ile business_cards kaydından güncel kartvizit bilgisini getirir.
  Future<SavedCard?> fetchPublicCardByCardId(String cardId);
  Future<void> trackPublicContactClick({
    required String cardId,
    required String contactType,
  });
  Future<SavedCard> addCard(SavedCard card);
  Future<void> saveCard(SavedCard card);
  Future<void> deleteCard(String cardId);
  Future<SavedCardsWalletQuota> getWalletQuota();

  /// Sunucuda premium + isOwnerPremium yazar; dönen kota premium olmalıdır.
  Future<SavedCardsWalletQuota> syncWalletPremium();

  Future<void> cacheFromProfile(List<SavedCard> cards);

  Future<List<WalletCardInvitation>> getPendingWalletCardInvitations();
  Future<void> acceptWalletCardInvitation(String invitationId);
  Future<void> rejectWalletCardInvitation(String invitationId);
}
