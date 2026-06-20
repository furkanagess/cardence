import '../../../auth/data/datasources/auth_remote_datasource.dart';
import '../entities/add_saved_card_result.dart';
import '../entities/saved_card.dart';
import '../repositories/saved_card_repository.dart';

class AddSavedCard {
  const AddSavedCard(this._cardRepository);

  final SavedCardRepository _cardRepository;

  Future<AddSavedCardResult> call(SavedCard card) async {
    final id = card.cardId.trim();
    if (id.isEmpty) {
      return const AddSavedCardInvalidPayload('Geçersiz kart kimliği.');
    }

    try {
      final savedAt = card.savedAt ?? DateTime.now().millisecondsSinceEpoch;
      var toSave = card.copyWith(cardId: id, savedAt: savedAt);

      final fromDb = await _cardRepository.fetchPublicCardByCardId(id);
      if (fromDb != null) {
        toSave = fromDb.copyWith(
          savedAt: savedAt,
          linkedEventGroupIds: card.linkedEventGroupIds,
          origin: card.origin,
        );
      }

      await _cardRepository.addCard(toSave);
      return const AddSavedCardSuccess();
    } on AuthApiException catch (e) {
      if (e.statusCode == 409 || e.errorCode == 'WALLET_DUPLICATE_CARD') {
        return const AddSavedCardDuplicate();
      }
      if (e.statusCode == 403 || e.errorCode == 'WALLET_LIMIT_REACHED') {
        final quota = await _cardRepository.getWalletQuota();
        return AddSavedCardLimitReached(quota);
      }
      if (e.statusCode == 403 &&
          (e.errorCode == 'PREMIUM_REQUIRED' ||
              e.errorCode == 'BUSINESS_CARD_LIMIT_REACHED')) {
        final quota = await _cardRepository.getWalletQuota();
        return AddSavedCardPremiumRequired(quota);
      }
      if (e.statusCode == 400 ||
          e.errorCode == 'VALIDATION_ERROR' ||
          e.errorCode == 'INVALID_CARD_PAYLOAD') {
        return AddSavedCardInvalidPayload(e.message);
      }
      if (e.statusCode == 404 || e.errorCode == 'CARD_NOT_FOUND') {
        return AddSavedCardInvalidPayload(
          'Kart bulunamadı. ID\'yi kontrol edin.',
        );
      }
      return AddSavedCardInvalidPayload(e.message);
    } catch (_) {
      return const AddSavedCardInvalidPayload(
        'Kart eklenemedi. Lütfen tekrar deneyin.',
      );
    }
  }
}
