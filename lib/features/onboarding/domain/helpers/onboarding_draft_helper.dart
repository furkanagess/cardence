import '../../../../core/utils/card_id_generator.dart';
import '../entities/onboarding_card_draft.dart';
import 'card_visibility_helper.dart';

/// Onboarding taslağını kayıt ve önizleme için normalize eder.
class OnboardingDraftHelper {
  OnboardingDraftHelper._();

  static OnboardingCardDraft ensureCardId(OnboardingCardDraft draft) {
    if (CardIdGenerator.isValid(draft.cardId)) return draft;
    return draft.copyWith(cardId: CardIdGenerator.generate());
  }

  static OnboardingCardDraft prepareForSave(OnboardingCardDraft draft) {
    final normalized = ensureCardId(draft);
    final cardId = normalized.cardId!.trim();
    final migrated = normalized.shouldMigrateFrontFields
        ? normalized.withStandardFrontFields()
        : normalized;

    return migrated.copyWith(
      cardId: cardId,
      displayName: draft.displayName?.trim(),
      company: draft.company?.trim(),
      title: draft.title?.trim(),
      email: draft.email?.trim(),
      frontVisibleFields:
          CardVisibilityHelper.normalizeFrontContactFields(
        migrated.frontVisibleFields,
      ),
      backVisibleFields: CardVisibilityHelper.normalizeBackFields(
        migrated.backVisibleFields,
      ),
    );
  }

  /// Önizleme adımında gösterilecek taslak.
  static OnboardingCardDraft forPreview(OnboardingCardDraft draft) {
    return prepareForSave(draft);
  }
}
