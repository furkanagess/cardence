import '../../../saved_cards/domain/entities/manual_saved_card_draft.dart';
import '../entities/onboarding_card_draft.dart';
import '../onboarding_draft_seeder.dart';

/// OCR / manuel cüzdan taslağını onboarding kart taslağına aktarır.
class ManualDraftToOnboardingMapper {
  ManualDraftToOnboardingMapper._();

  static OnboardingCardDraft merge(
    OnboardingCardDraft base,
    ManualSavedCardDraft scanned,
  ) {
    final merged = base.copyWith(
      displayName: _prefer(scanned.displayName, base.displayName),
      email: _prefer(scanned.email, base.email),
      phone: _prefer(scanned.phone, base.phone),
      company: _prefer(scanned.company, base.company),
      title: _prefer(scanned.title, base.title),
      website: _prefer(scanned.website, base.website),
      linkedin: _prefer(scanned.linkedin, base.linkedin),
      about: _prefer(scanned.about, base.about),
      skills: _prefer(scanned.skills, base.skills),
      accentColor: _prefer(scanned.accentColor, base.accentColor),
      backgroundColor: _prefer(scanned.backgroundColor, base.backgroundColor),
    );

    return OnboardingDraftSeeder.enrichLinkedInCard(merged);
  }

  static String? _prefer(String? primary, String? fallback) {
    final value = primary?.trim();
    if (value != null && value.isNotEmpty) return value;
    final existing = fallback?.trim();
    if (existing != null && existing.isNotEmpty) return existing;
    return null;
  }
}
