import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/organisms/flippable_person_card.dart';
import '../../../../core/widgets/organisms/person_info_card.dart';
import '../../../onboarding/domain/entities/onboarding_card_draft.dart';

/// Kendi kart onizlemesi: yalnizca on yuz (not/arka yuz kullanicinin kendi kartinda yok).
class MyCardPreviewHelpers {
  MyCardPreviewHelpers._();

  static const Map<String, String> fieldLabels = {
    'displayName': 'Ad Soyad',
    'email': 'E-posta',
    'phone': 'Telefon',
    'company': 'Şirket',
    'title': 'Ünvan',
    'website': 'Web sitesi',
    'linkedin': 'LinkedIn',
    'skills': 'Yetenekler',
    'school': 'Okul',
    'about': 'Hakkımda',
  };

  static Color? parseHexColor(String? hex) {
    if (hex == null || hex.length != 7 || !hex.startsWith('#')) return null;
    return Color(int.parse(hex.substring(1), radix: 16) + 0xFF000000);
  }

  static String? fieldValue(OnboardingCardDraft draft, String key) {
    switch (key) {
      case 'displayName':
        return draft.displayName;
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
    final keys = draft.resolvedFrontVisibleFields
        .take(AppConstants.maxFrontCardFields)
        .toList();
    return keys
        .map((key) => (label: fieldLabels[key]!, value: fieldValue(draft, key)))
        .where((e) => e.value != null && e.value!.trim().isNotEmpty)
        .map((e) => (label: e.label, value: e.value!))
        .toList();
  }

  static List<({String label, String value})> backEntries(
    OnboardingCardDraft draft,
  ) {
    final keys = draft.backVisibleFields.isEmpty
        ? OnboardingCardDraft.backFieldKeys
            .take(AppConstants.maxBackCardFields)
            .toList()
        : draft.backVisibleFields
            .take(AppConstants.maxBackCardFields)
            .toList();
    return keys
        .map((key) => (label: fieldLabels[key]!, value: fieldValue(draft, key)))
        .where((e) => e.value != null && e.value!.trim().isNotEmpty)
        .map((e) => (label: e.label, value: e.value!))
        .toList();
  }

  static Widget flippableCard({
    required OnboardingCardDraft draft,
    VoidCallback? onTap,
    String emptyMessage = 'Bilgi girildikçe kartta görünür',
    Key? key,
  }) {
    final card = PersonInfoCard(
      title: draft.displayName?.trim().isEmpty ?? true
          ? 'Ad Soyad'
          : draft.displayName,
      titleSecondary: draft.company?.trim(),
      entries: frontEntries(draft),
      emptyMessage: emptyMessage,
      compact: true,
      accentColor: parseHexColor(draft.accentColor),
      backgroundColor: parseHexColor(draft.backgroundColor),
    );

    return SizedBox(
      key: key,
      height: FlippablePersonCard.fixedHeight,
      child: onTap != null
          ? GestureDetector(onTap: onTap, child: card)
          : card,
    );
  }
}
