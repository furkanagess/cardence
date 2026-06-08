import 'package:uuid/uuid.dart';

import '../domain/entities/onboarding_card_draft.dart';

/// Onboarding taslağını kayıt ve önizleme için normalize eder.
class OnboardingDraftHelper {
  OnboardingDraftHelper._();

  static bool _hasValue(OnboardingCardDraft draft, String key) {
    final v = switch (key) {
      'email' => draft.email,
      'phone' => draft.phone,
      'company' => draft.company,
      'title' => draft.title,
      'website' => draft.website,
      'linkedin' => draft.linkedin,
      'skills' => draft.skills,
      'school' => draft.school,
      'about' => draft.about,
      _ => null,
    };
    return v != null && v.trim().isNotEmpty;
  }

  static List<String> resolveFrontFields(OnboardingCardDraft draft) {
    const priority = ['company', 'title', 'email', 'phone', 'skills'];
    final fields = <String>[];
    for (final key in priority) {
      if (_hasValue(draft, key)) fields.add(key);
      if (fields.length >= 3) break;
    }
    if (fields.isEmpty) {
      return List<String>.from(OnboardingCardDraft.defaultFrontVisibleFields);
    }
    return fields;
  }

  static List<String> resolveBackFields(OnboardingCardDraft draft) {
    const priority = ['phone', 'email', 'website', 'linkedin'];
    final fields = <String>[];
    for (final key in priority) {
      if (_hasValue(draft, key) && !fields.contains(key)) {
        fields.add(key);
      }
      if (fields.length >= 3) break;
    }
    return fields;
  }

  static OnboardingCardDraft prepareForSave(OnboardingCardDraft draft) {
    final cardId = (draft.cardId?.trim().isNotEmpty ?? false)
        ? draft.cardId!
        : const Uuid().v4();

    return draft.copyWith(
      cardId: cardId,
      displayName: draft.displayName?.trim(),
      company: draft.company?.trim(),
      title: draft.title?.trim(),
      email: draft.email?.trim(),
      frontVisibleFields: resolveFrontFields(draft),
      backVisibleFields: resolveBackFields(draft),
    );
  }

  /// Önizleme adımında gösterilecek taslak.
  static OnboardingCardDraft forPreview(OnboardingCardDraft draft) {
    return draft.copyWith(
      frontVisibleFields: resolveFrontFields(draft),
      backVisibleFields: resolveBackFields(draft),
    );
  }
}
