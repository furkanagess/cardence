import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/organisms/flippable_person_card.dart';
import '../../../../core/widgets/organisms/person_info_card.dart';
import '../domain/entities/onboarding_card_draft.dart';

/// Onboarding önizlemesi için kart girişleri.
class OnboardingPreviewHelpers {
  OnboardingPreviewHelpers._();

  static const Map<String, String> _fieldLabels = {
    'email': 'E-posta',
    'phone': 'Telefon',
    'company': 'Şirket',
    'title': 'Pozisyon',
    'website': 'Web',
    'linkedin': 'LinkedIn',
    'skills': 'Yetenekler',
    'school': 'Okul',
    'about': 'Hakkımda',
  };

  static String? _value(OnboardingCardDraft draft, String key) {
    switch (key) {
      case 'email':
        return draft.email;
      case 'phone':
        return draft.phone;
      case 'company':
        return draft.company;
      case 'title':
        return draft.title;
      case 'website':
        return draft.website;
      case 'linkedin':
        return draft.linkedin;
      case 'skills':
        return draft.skills;
      case 'school':
        return draft.school;
      case 'about':
        return draft.about;
      default:
        return null;
    }
  }

  static List<({String label, String value})> frontEntries(
    OnboardingCardDraft draft,
  ) {
    return draft.resolvedFrontVisibleFields
        .take(AppConstants.maxFrontCardFields)
        .map((key) => (label: _fieldLabels[key] ?? key, value: _value(draft, key)))
        .where((e) => e.value != null && e.value!.trim().isNotEmpty)
        .map((e) => (label: e.label, value: e.value!))
        .toList();
  }

  /// Kendi kart önizlemesi: yalnızca ön yüz, çevrilemez.
  static Widget preview(OnboardingCardDraft draft) {
    final name = draft.displayName?.trim();
    return SizedBox(
      height: FlippablePersonCard.fixedHeight,
      child: PersonInfoCard(
        title: (name == null || name.isEmpty) ? 'Ad Soyad' : name,
        titleSecondary: draft.company?.trim(),
        entries: frontEntries(draft),
        emptyMessage: 'Alanlar doldukça görünür',
        compact: true,
      ),
    );
  }
}
