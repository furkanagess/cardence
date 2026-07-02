import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/add_saved_card_result.dart';

String? addCardByIdFormError(
  AppLocalizations l10n,
  AddSavedCardResult? result,
) {
  return switch (result) {
    AddSavedCardDuplicate() => l10n.kartZatenKaytl,
    AddSavedCardInvalidPayload(:final message) =>
      message.isEmpty ? l10n.invalidCardId : message,
    _ => null,
  };
}

({String title, String message}) addCardByIdFailureMessages(
  AppLocalizations l10n,
  AddSavedCardResult result,
) {
  return switch (result) {
    AddSavedCardLimitReached() => (
        title: l10n.kartCzdanaEklenemedi,
        message: l10n.walletFullUpgradeLimit,
      ),
    AddSavedCardPremiumRequired() => (
        title: l10n.kartCzdanaEklenemedi,
        message: l10n.premiumRequired,
      ),
    _ => (
        title: l10n.kartCzdanaEklenemedi,
        message: l10n.invalidCardId,
      ),
  };
}
