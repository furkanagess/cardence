import '../entities/onboarding_card_draft.dart';
import '../repositories/onboarding_repository.dart';

/// Onboarding sırasında kaydedilen kart taslağını getirir.
class GetOnboardingDraftCard {
  const GetOnboardingDraftCard(this._repository);

  final OnboardingRepository _repository;

  Future<OnboardingCardDraft?> call() => _repository.getDraftCard();
}
