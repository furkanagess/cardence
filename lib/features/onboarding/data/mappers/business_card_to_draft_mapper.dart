import '../../../business_cards/domain/entities/business_card.dart';
import '../../domain/entities/onboarding_card_draft.dart';
import '../../../my_cards/presentation/card_customize_colors.dart';

class BusinessCardToDraftMapper {
  BusinessCardToDraftMapper._();

  static String? _localLastUsedPaletteBackground(String? backgroundColor) {
    if (backgroundColor == null ||
        backgroundColor.length != 7 ||
        !backgroundColor.startsWith('#')) {
      return null;
    }
    if (cardBackgroundColorOptions.contains(backgroundColor)) {
      return null;
    }
    return backgroundColor;
  }

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
      address: card.address,
      city: card.city,
      country: card.country,
      department: card.department,
      attendedEvents: card.attendedEvents,
      twitter: card.twitter,
      instagram: card.instagram,
      birthday: card.birthday,
      photoUrl: card.photoUrl,
      accentColor: card.accentColor,
      backgroundColor: card.backgroundColor,
      lastUsedPaletteBackgroundColor:
          _localLastUsedPaletteBackground(card.backgroundColor),
      cardId: card.cardId,
    );
  }
}
