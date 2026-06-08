import '../../../onboarding/domain/entities/onboarding_card_draft.dart';
import '../../domain/entities/business_card.dart';

class OnboardingDraftMapper {
  OnboardingDraftMapper._();

  static BusinessCard toBusinessCard(OnboardingCardDraft draft) {
    return BusinessCard(
      cardName: draft.cardName?.trim().isNotEmpty == true
          ? draft.cardName!.trim()
          : draft.listTitle,
      displayName: draft.displayName?.trim(),
      email: draft.email?.trim(),
      phone: draft.phone?.trim().isNotEmpty == true ? draft.phone!.trim() : null,
      company: draft.company?.trim(),
      title: draft.title?.trim(),
      website: draft.website?.trim().isNotEmpty == true
          ? draft.website!.trim()
          : null,
      linkedin: draft.linkedin?.trim().isNotEmpty == true
          ? draft.linkedin!.trim()
          : null,
      skills: draft.skills?.trim().isNotEmpty == true
          ? draft.skills!.trim()
          : null,
      school: draft.school?.trim().isNotEmpty == true
          ? draft.school!.trim()
          : null,
      about: draft.about?.trim().isNotEmpty == true ? draft.about!.trim() : null,
      accentColor: draft.accentColor,
      backgroundColor: draft.backgroundColor,
      lastUsedPaletteBackgroundColor: draft.lastUsedPaletteBackgroundColor,
      cardId: draft.cardId?.trim(),
    );
  }
}
