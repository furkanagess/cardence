import '../../../business_cards/domain/entities/business_card.dart';
import '../../domain/entities/onboarding_card_draft.dart';

class BusinessCardToDraftMapper {
  BusinessCardToDraftMapper._();

  static OnboardingCardDraft fromBusinessCard(BusinessCard card) {
    return OnboardingCardDraft(
      cardName: card.cardName,
      displayName: card.displayName,
      email: card.email,
      phone: card.phone,
      company: card.company,
      title: card.title,
      website: card.website,
      linkedin: card.linkedin,
      skills: card.skills,
      school: card.school,
      about: card.about,
      photoUrl: card.photoUrl,
      accentColor: card.accentColor,
      backgroundColor: card.backgroundColor,
      lastUsedPaletteBackgroundColor: card.lastUsedPaletteBackgroundColor,
      cardId: card.cardId,
    );
  }
}
