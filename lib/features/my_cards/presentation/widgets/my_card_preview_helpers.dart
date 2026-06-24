import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../onboarding/presentation/widgets/onboarding_card_preview_frame.dart';
import '../../../onboarding/domain/entities/onboarding_card_draft.dart';

/// Kendi kart önizlemesi — onboarding ile birebir aynı bileşen.
class MyCardPreviewHelpers {
  MyCardPreviewHelpers._();

  static Map<String, String> fieldLabels(AppLocalizations l10n) => {
        'displayName': l10n.adSoyad,
        'email': l10n.ePosta,
        'phone': l10n.telefon,
        'company': l10n.irket,
        'title': l10n.nvlan,
        'website': l10n.webSitesi,
        'linkedin': l10n.linkedin,
        'skills': l10n.yetenekler,
        'school': l10n.okul,
        'about': l10n.hakkmda,
        'address': l10n.adres,
        'city': l10n.ehir,
        'country': l10n.lke,
        'department': l10n.departman,
        'attendedEvents': l10n.katldEtkinlikler,
        'twitter': 'Twitter / X',
        'instagram': l10n.instagram,
        'birthday': l10n.doumGn,
      };

  static Color? parseHexColor(String? hex) {
    if (hex == null || hex.length != 7 || !hex.startsWith('#')) return null;
    return Color(int.parse(hex.substring(1), radix: 16) + 0xFF000000);
  }

  static Widget flippableCard({
    required OnboardingCardDraft draft,
    required AppLocalizations l10n,
    VoidCallback? onTap,
    VoidCallback? onDoubleTap,
    String? emptyMessage,
    Key? key,
  }) {
    return OnboardingCardPreviewFrame(
      key: key,
      draft: draft,
      onTap: onTap,
      onDoubleTap: onDoubleTap,
      emptyMessage: emptyMessage ?? l10n.alanlarDoldukaGrnr,
      normalizeForDisplay: true,
    );
  }
}
