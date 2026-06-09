import '../../auth/domain/entities/user_profile.dart';
import 'entities/onboarding_card_draft.dart';

/// Kullanıcı profilinden onboarding kart taslağına alan aktarımı.
class OnboardingDraftSeeder {
  OnboardingDraftSeeder._();

  static OnboardingCardDraft defaultDraft() => OnboardingCardDraft(
        frontVisibleFields: List<String>.from(
          OnboardingCardDraft.defaultFrontVisibleFields,
        ),
      );

  static OnboardingCardDraft applyUserProfile(
    OnboardingCardDraft base,
    UserProfile profile,
  ) {
    return base.copyWith(
      displayName: _fill(base.displayName, profile.displayName),
      email: _fill(base.email, profile.email),
      phone: _fill(base.phone, profile.phone),
    );
  }

  static String? _fill(String? current, String? incoming) {
    if (current != null && current.trim().isNotEmpty) return current;
    final value = incoming?.trim();
    if (value == null || value.isEmpty) return null;
    return value;
  }
}
