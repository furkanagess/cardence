import '../../../../core/network/auth_api_exception.dart';
import '../../../../core/utils/card_id_generator.dart';
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

  static const _maxDuplicateRetries = 5;

  Future<OnboardingCardDraft> call(OnboardingCardDraft draft) async {
    var prepared = OnboardingDraftHelper.prepareForSave(draft);
    await _saveOnboardingDraftCard(prepared);

    for (var attempt = 0; attempt < _maxDuplicateRetries; attempt++) {
      try {
        final saved = await _upsertBusinessCard(
          OnboardingDraftMapper.toBusinessCard(prepared),
        );
        final synced = prepared.copyWith(
          cardId: saved.cardId ?? prepared.cardId,
        );
        await _saveOnboardingDraftCard(synced);
        return synced;
      } on AuthApiException catch (e) {
        if (_isDuplicateCardIdError(e) && attempt < _maxDuplicateRetries - 1) {
          prepared = prepared.copyWith(cardId: CardIdGenerator.generate());
          await _saveOnboardingDraftCard(prepared);
          continue;
        }
        rethrow;
      } catch (_) {
        throw AuthApiException(
          'Kart sunucuya kaydedilemedi. Lütfen tekrar deneyin.',
        );
      }
    }

    throw AuthApiException('Kart kimliği oluşturulamadı. Lütfen tekrar deneyin.');
  }

  bool _isDuplicateCardIdError(AuthApiException error) {
    final message = error.message.toLowerCase();
    return message.contains('already in use')
        || message.contains('duplicate')
        || message.contains('zaten');
  }
}
