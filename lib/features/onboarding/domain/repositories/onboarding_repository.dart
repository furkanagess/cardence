import '../entities/onboarding_card_draft.dart';

/// Onboarding tamamlandı mı / kaydet – Domain interface (implementation Data katmanında).
abstract class OnboardingRepository {
  Future<bool> isOnboardingCompleted();
  Future<void> setOnboardingCompleted();
  Future<void> saveDraftCard(OnboardingCardDraft draft);
  Future<OnboardingCardDraft?> getDraftCard();
  Future<List<OnboardingCardDraft>> getDraftCards();
}
