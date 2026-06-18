import '../entities/onboarding_card_draft.dart';

/// Kart ön/arka yüz görünürlük kuralları.
class CardVisibilityHelper {
  CardVisibilityHelper._();

  static const Map<String, String> contactFieldLabels = {
    'email': 'E-posta',
    'phone': 'Telefon',
    'linkedin': 'LinkedIn',
    'website': 'Web sitesi',
  };

  static const Map<String, String> backFieldLabels = {
    'skills': 'Yetenekler',
  };

  static bool hasValue(OnboardingCardDraft draft, String key) {
    final value = fieldValue(draft, key);
    return value != null && value.trim().isNotEmpty;
  }

  static String? fieldValue(OnboardingCardDraft draft, String key) {
    switch (key) {
      case 'email':
        return draft.email;
      case 'phone':
        return draft.phone;
      case 'linkedin':
        return draft.linkedin;
      case 'website':
        return draft.website;
      case 'skills':
        return draft.skills;
      case 'about':
        return draft.about;
      default:
        return null;
    }
  }

  /// Ön yüz alt iletişim satırlarında gösterilecek anahtarlar (değeri olanlar).
  static List<String> visibleFrontContactKeys(OnboardingCardDraft draft) {
    return draft.resolvedFrontContactFields
        .where((key) => hasValue(draft, key))
        .toList();
  }

  static String? visibleContactValue(OnboardingCardDraft draft, String key) {
    if (!visibleFrontContactKeys(draft).contains(key)) return null;
    return fieldValue(draft, key)?.trim();
  }

  static List<({String label, String value})> backEntries(
    OnboardingCardDraft draft,
  ) {
    final items = <({String label, String value})>[];
    final about = draft.about?.trim();
    items.add((
      label: 'Hakkımda',
      value: (about != null && about.isNotEmpty) ? about : '',
    ));

    if (draft.showSkillsOnBack) {
      final skills = draft.skills?.trim();
      if (skills != null && skills.isNotEmpty) {
        items.add((label: 'Yetenekler', value: skills));
      }
    }

    return items;
  }

  static List<String> normalizeFrontContactFields(List<String> fields) {
    return fields
        .where((key) => OnboardingCardDraft.cardFrontContactFieldKeys.contains(key))
        .toList();
  }

  static List<String> normalizeBackFields(List<String> fields) {
    return fields
        .where((key) => OnboardingCardDraft.backFieldKeys.contains(key))
        .toList();
  }
}
