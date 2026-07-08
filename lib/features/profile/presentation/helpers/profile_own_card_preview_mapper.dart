import '../../../onboarding/domain/entities/onboarding_card_draft.dart';
import '../../../saved_cards/domain/entities/card_creation_method.dart';
import '../../../saved_cards/domain/entities/saved_card.dart';
import '../../../saved_cards/domain/entities/saved_card_origin.dart';

/// Profil sekmesindeki kendi kartını [SavedCardDetailPage] önizlemesine dönüştürür.
SavedCard profileOwnCardPreviewFromDraft(
  OnboardingCardDraft draft, {
  bool isOwnerPremium = false,
}) {
  final cardId = draft.cardId?.trim();
  return SavedCard(
    cardId: cardId != null && cardId.isNotEmpty ? cardId : 'own-card-preview',
    origin: SavedCardOrigin.cardence,
    creationMethod: CardCreationMethod.cardenceLink,
    displayName: draft.displayName,
    email: draft.email,
    phone: draft.phone,
    company: draft.company,
    title: draft.title,
    website: draft.website,
    linkedin: draft.linkedin,
    skills: draft.skills,
    school: draft.school,
    about: draft.about,
    address: draft.address,
    city: draft.city,
    country: draft.country,
    department: draft.department,
    attendedEvents: draft.attendedEvents,
    twitter: draft.twitter,
    instagram: draft.instagram,
    birthday: draft.birthday,
    photoUrl: draft.photoUrl,
    accentColor: draft.accentColor,
    backgroundColor: draft.backgroundColor,
    isOwnerPremium: isOwnerPremium,
  );
}
