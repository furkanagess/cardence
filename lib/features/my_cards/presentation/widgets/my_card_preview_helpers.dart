import 'package:flutter/material.dart';

import '../../../onboarding/presentation/widgets/onboarding_card_preview_frame.dart';
import '../../../onboarding/domain/entities/onboarding_card_draft.dart';

/// Kendi kart önizlemesi — onboarding ile birebir aynı bileşen.
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

  static Widget flippableCard({
    required OnboardingCardDraft draft,
    VoidCallback? onTap,
    VoidCallback? onDoubleTap,
    String emptyMessage = 'Alanlar doldukça görünür',
    Key? key,
  }) {
    return OnboardingCardPreviewFrame(
      key: key,
      draft: draft,
      onTap: onTap,
      onDoubleTap: onDoubleTap,
      emptyMessage: emptyMessage,
      normalizeForDisplay: true,
    );
  }
}
