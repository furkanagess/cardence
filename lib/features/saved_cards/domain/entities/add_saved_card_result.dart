import 'saved_cards_wallet_quota.dart';

/// Kart ekleme use case sonucu.
sealed class AddSavedCardResult {
  const AddSavedCardResult();
}

class AddSavedCardSuccess extends AddSavedCardResult {
  const AddSavedCardSuccess();
}

class AddSavedCardDuplicate extends AddSavedCardResult {
  const AddSavedCardDuplicate();
}

class AddSavedCardLimitReached extends AddSavedCardResult {
  const AddSavedCardLimitReached(this.quota);

  final SavedCardsWalletQuota quota;
}

class AddSavedCardInvalidPayload extends AddSavedCardResult {
  const AddSavedCardInvalidPayload(this.message);

  final String message;
}
