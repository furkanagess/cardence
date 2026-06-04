import '../entities/onboarding_card_draft.dart';
import '../repositories/onboarding_repository.dart';

/// Onboarding kart taslağını yerel olarak kaydeder.
class SaveOnboardingDraftCard {
  const SaveOnboardingDraftCard(this._repository);

  final OnboardingRepository _repository;

  Future<void> call(OnboardingCardDraft draft) => _repository.saveDraftCard(
        draft.copyWith(linkedEventGroupIds: const []),
      );
}
