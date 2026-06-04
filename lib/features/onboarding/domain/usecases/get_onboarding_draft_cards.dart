import '../entities/onboarding_card_draft.dart';
import '../repositories/onboarding_repository.dart';

/// Tüm kart taslaklarını getirir (çoklu kart desteği).
class GetOnboardingDraftCards {
  const GetOnboardingDraftCards(this._repository);

  final OnboardingRepository _repository;

  Future<List<OnboardingCardDraft>> call() => _repository.getDraftCards();
}
