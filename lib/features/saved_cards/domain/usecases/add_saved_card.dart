import '../entities/add_saved_card_result.dart';
import '../entities/saved_card.dart';
import '../repositories/saved_card_repository.dart';
import 'get_saved_cards_wallet_quota.dart';

class AddSavedCard {
  const AddSavedCard(
    this._cardRepository,
    this._getQuota,
  );

  final SavedCardRepository _cardRepository;
  final GetSavedCardsWalletQuota _getQuota;

  Future<AddSavedCardResult> call(SavedCard card) async {
    final id = card.cardId.trim();
    if (id.isEmpty) {
      return const AddSavedCardInvalidPayload('Geçersiz kart kimliği.');
    }

    final existing = await _cardRepository.getSavedCards();
    if (existing.any((c) => c.cardId == id)) {
      return const AddSavedCardDuplicate();
    }

    final quota = await _getQuota();
    if (!quota.canAddMore) {
      return AddSavedCardLimitReached(quota);
    }

    await _cardRepository.saveCard(
      card.copyWith(cardId: id, savedAt: card.savedAt ?? DateTime.now().millisecondsSinceEpoch),
    );
    return const AddSavedCardSuccess();
  }
}
