import '../../auth/domain/entities/user_profile.dart';
import 'entities/onboarding_card_draft.dart';

/// Kullanıcı profilinden onboarding kart taslağına alan aktarımı.
class OnboardingDraftSeeder {
  OnboardingDraftSeeder._();

  static OnboardingCardDraft defaultDraft() => OnboardingCardDraft(
        frontVisibleFields: List<String>.from(
          OnboardingCardDraft.defaultFrontVisibleFields,
        ),
        backVisibleFields: List<String>.from(
          OnboardingCardDraft.defaultBackVisibleFields,
        ),
        backgroundColor: '#1B365D',
        accentColor: '#FFFFFF',
      );

  static OnboardingCardDraft applyUserProfile(
    OnboardingCardDraft base,
    UserProfile profile,
  ) {
    var draft = base.copyWith(
      displayName: _fill(base.displayName, profile.displayName),
      email: _fill(base.email, profile.email),
      phone: _fill(base.phone, profile.phone),
      photoUrl: _fill(base.photoUrl, profile.photoUrl),
    );

    if (profile.businessCards.isEmpty) {
      return draft;
    }

    final card = profile.businessCards.first;
    return draft.copyWith(
      displayName: _fill(draft.displayName, card.displayName),
      email: _fill(draft.email, card.email),
      phone: _fill(draft.phone, card.phone),
      photoUrl: _fill(draft.photoUrl, card.photoUrl),
      company: _fill(draft.company, card.company),
      title: _fill(draft.title, card.title),
      website: _fill(draft.website, card.website),
      linkedin: _fill(draft.linkedin, card.linkedin),
      cardId: _fill(draft.cardId, card.cardId),
    );
  }

  static String? _fill(String? current, String? incoming) {
    if (current != null && current.trim().isNotEmpty) return current;
    final value = incoming?.trim();
    if (value == null || value.isEmpty) return null;
    return value;
  }
}
