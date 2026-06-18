import '../../onboarding/domain/entities/onboarding_card_draft.dart';
import '../domain/entities/manual_saved_card_draft.dart';

/// Manuel kart taslağını onboarding önizleme modeline dönüştürür.
class ManualSavedCardPreviewHelper {
  ManualSavedCardPreviewHelper._();

  static OnboardingCardDraft toPreviewDraft(ManualSavedCardDraft draft) {
    final backFields = List<String>.from(
      OnboardingCardDraft.defaultBackVisibleFields,
    );
    if (draft.skills != null && draft.skills!.trim().isNotEmpty) {
      backFields.add('skills');
    }

    return OnboardingCardDraft(
      displayName: draft.displayName,
      email: draft.email,
      phone: draft.phone,
      company: draft.company,
      title: draft.title,
      website: draft.website,
      linkedin: draft.linkedin,
      about: draft.about,
      skills: draft.skills,
      accentColor: draft.accentColor,
      backgroundColor: draft.backgroundColor,
      frontVisibleFields: List<String>.from(
        OnboardingCardDraft.defaultFrontVisibleFields,
      ),
      backVisibleFields: backFields,
    );
  }
}
