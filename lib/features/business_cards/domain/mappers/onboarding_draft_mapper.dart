import '../../../onboarding/domain/entities/onboarding_card_draft.dart';
import '../entities/business_card.dart';

class OnboardingDraftMapper {
  OnboardingDraftMapper._();

  static String? _trimOrNull(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) return null;
    return trimmed;
  }

  static BusinessCard toBusinessCard(OnboardingCardDraft draft) {
    return BusinessCard(
      cardName: draft.cardName?.trim().isNotEmpty == true
          ? draft.cardName!.trim()
          : draft.listTitle,
      displayName: _trimOrNull(draft.displayName),
      email: _trimOrNull(draft.email),
      phone: _trimOrNull(draft.phone),
      company: _trimOrNull(draft.company),
      title: _trimOrNull(draft.title),
      website: _trimOrNull(draft.website),
      linkedin: _trimOrNull(draft.linkedin),
      skills: _trimOrNull(draft.skills),
      school: _trimOrNull(draft.school),
      about: _trimOrNull(draft.about),
      address: _trimOrNull(draft.address),
      city: _trimOrNull(draft.city),
      country: _trimOrNull(draft.country),
      department: _trimOrNull(draft.department),
      attendedEvents: _trimOrNull(draft.attendedEvents),
      twitter: _trimOrNull(draft.twitter),
      instagram: _trimOrNull(draft.instagram),
      birthday: _trimOrNull(draft.birthday),
      photoUrl: _trimOrNull(draft.photoUrl),
      accentColor: draft.accentColor,
      backgroundColor: draft.backgroundColor,
      lastUsedPaletteBackgroundColor: draft.lastUsedPaletteBackgroundColor,
      cardId: draft.cardId?.trim(),
    );
  }
}
