import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../core/domain/card_visual_effect.dart';
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
        'twitter': l10n.twitterX,
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
    VoidCallback? onDetailTap,
    VoidCallback? onDoubleTap,
    String? emptyMessage,
    bool gatePremiumEffects = false,
    bool showActionStrip = true,
    bool contactFieldsTappable = true,
    String? heroTag,
    Key? key,
  }) {
    return OnboardingCardPreviewFrame(
      key: key,
      draft: draft,
      onTap: onTap,
      onDetailTap: onDetailTap,
      onDoubleTap: onDoubleTap,
      emptyMessage: emptyMessage ?? l10n.alanlarDoldukaGrnr,
      normalizeForDisplay: true,
      gatePremiumEffects: gatePremiumEffects,
      showActionStrip: showActionStrip,
      contactFieldsTappable: contactFieldsTappable,
      heroTag: heroTag,
    );
  }

  static Widget flippableCardWithColors({
    required OnboardingCardDraft draft,
    required AppLocalizations l10n,
    String? backgroundColor,
    String? accentColor,
    CardVisualEffect? cardEffect,
    String? emptyMessage,
    bool showActionStrip = true,
  }) {
    return flippableCard(
      draft: draft.copyWith(
        backgroundColor: backgroundColor,
        accentColor: accentColor,
        cardEffect: cardEffect,
        clearBackgroundColor: backgroundColor == null,
        clearAccentColor: accentColor == null,
      ),
      l10n: l10n,
      emptyMessage: emptyMessage,
      showActionStrip: showActionStrip,
    );
  }
}
