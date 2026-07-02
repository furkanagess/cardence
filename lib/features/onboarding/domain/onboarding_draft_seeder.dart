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
        backgroundColor: '#0F5C6E',
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
      return enrichLinkedInCard(draft);
    }

    final card = profile.businessCards.first;
    draft = draft.copyWith(
      displayName: _prefer(draft.displayName, card.displayName),
      email: _prefer(draft.email, card.email),
      phone: _prefer(draft.phone, card.phone),
      photoUrl: _prefer(draft.photoUrl, card.photoUrl),
      company: _prefer(draft.company, card.company),
      title: _prefer(draft.title, card.title),
      website: _prefer(draft.website, card.website),
      linkedin: _prefer(draft.linkedin, card.linkedin),
      about: _prefer(draft.about, card.about),
      school: _prefer(draft.school, card.school),
      skills: _prefer(draft.skills, card.skills),
      cardId: _prefer(draft.cardId, card.cardId),
      accentColor: _prefer(draft.accentColor, card.accentColor),
      backgroundColor: _prefer(draft.backgroundColor, card.backgroundColor),
    );

    return enrichLinkedInCard(draft);
  }

  /// LinkedIn / profil kaynaklı kartta önizleme alanlarını doldurur.
  static OnboardingCardDraft enrichLinkedInCard(OnboardingCardDraft draft) {
    final hasLinkedInData = _has(draft.displayName) ||
        _has(draft.email) ||
        _has(draft.linkedin) ||
        _has(draft.company) ||
        _has(draft.title) ||
        _has(draft.school) ||
        _has(draft.about);

    if (!hasLinkedInData) {
      return draft;
    }

    final frontFields = <String>[];
    for (final key in const ['email', 'linkedin', 'phone', 'website']) {
      if (!_has(_fieldValue(draft, key))) continue;
      if (frontFields.contains(key)) continue;
      frontFields.add(key);
      if (frontFields.length >= 3) break;
    }

    final backFields = List<String>.from(draft.backVisibleFields);
    if (_has(draft.about) && !backFields.contains('about')) {
      backFields.insert(0, 'about');
    }
    if (_has(draft.skills) && !backFields.contains('skills')) {
      backFields.add('skills');
    }

    return draft.copyWith(
      frontVisibleFields:
          frontFields.isNotEmpty ? frontFields : draft.frontVisibleFields,
      backVisibleFields:
          backFields.isNotEmpty ? backFields : draft.backVisibleFields,
    );
  }

  static String? _fieldValue(OnboardingCardDraft draft, String key) {
    switch (key) {
      case 'email':
        return draft.email;
      case 'linkedin':
        return draft.linkedin;
      case 'phone':
        return draft.phone;
      case 'website':
        return draft.website;
      default:
        return null;
    }
  }

  static String? _fill(String? current, String? incoming) {
    if (current != null && current.trim().isNotEmpty) return current;
    final value = incoming?.trim();
    if (value == null || value.isEmpty) return null;
    return value;
  }

  static String? _prefer(String? current, String? incoming) {
    final next = incoming?.trim();
    if (next != null && next.isNotEmpty) return next;
    final existing = current?.trim();
    if (existing != null && existing.isNotEmpty) return existing;
    return null;
  }

  static bool _has(String? value) =>
      value != null && value.trim().isNotEmpty;
}
