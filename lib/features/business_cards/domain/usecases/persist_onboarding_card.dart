import '../../../../core/network/auth_api_exception.dart';
import '../../../onboarding/domain/entities/onboarding_card_draft.dart';
import '../../../onboarding/domain/helpers/onboarding_draft_helper.dart';
import '../../../onboarding/domain/usecases/save_onboarding_draft_card.dart';
import '../mappers/onboarding_draft_mapper.dart';
import 'upsert_business_card.dart';

/// Kartı yerelde kaydeder ve sunucuya POST/PUT ile senkronize eder.
class PersistOnboardingCard {
  const PersistOnboardingCard(
    this._saveOnboardingDraftCard,
    this._upsertBusinessCard,
  );

  final SaveOnboardingDraftCard _saveOnboardingDraftCard;
  final UpsertBusinessCard _upsertBusinessCard;

  Future<OnboardingCardDraft> call(OnboardingCardDraft draft) async {
    final prepared = OnboardingDraftHelper.prepareForSave(draft);
    await _saveOnboardingDraftCard(prepared);

    try {
      final saved = await _upsertBusinessCard(
        OnboardingDraftMapper.toBusinessCard(prepared),
      );
      final synced = prepared.copyWith(
        cardId: saved.cardId ?? prepared.cardId,
      );
      await _saveOnboardingDraftCard(synced);
      return synced;
    } on AuthApiException {
      rethrow;
    } catch (_) {
      throw AuthApiException('Kart sunucuya kaydedilemedi. Lütfen tekrar deneyin.');
    }
  }
}
