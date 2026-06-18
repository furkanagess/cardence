import 'package:flutter/material.dart';

import '../../../../core/widgets/organisms/flippable_person_card.dart';
import '../../my_cards/presentation/widgets/my_card_preview_helpers.dart';
import '../domain/entities/onboarding_card_draft.dart';
import '../domain/helpers/card_visibility_helper.dart';

/// Onboarding önizlemesi için kart girişleri.
class OnboardingPreviewHelpers {
  OnboardingPreviewHelpers._();

  /// Canlı kart önizlemesi; çevrilebilir.
  static Widget preview(
    OnboardingCardDraft draft, {
    bool flipOnTouch = false,
    VoidCallback? onTap,
    VoidCallback? onDoubleTap,
    String emptyMessage = 'Alanlar doldukça görünür',
  }) {
    final name = draft.displayName?.trim();
    return FlippablePersonCard(
      title: (name == null || name.isEmpty) ? 'Ad Soyad' : name,
      titleSecondary: draft.company?.trim(),
      jobTitle: draft.title?.trim(),
      frontEntries: const [],
      backEntries: CardVisibilityHelper.backEntries(draft),
      emptyMessage: emptyMessage,
      flipOnTouch: flipOnTouch,
      onTap: onTap,
      onDoubleTap: onDoubleTap,
      accentColor: MyCardPreviewHelpers.parseHexColor(draft.accentColor),
      backgroundColor:
          MyCardPreviewHelpers.parseHexColor(draft.backgroundColor),
      photoUrl: draft.photoUrl,
      cardId: draft.cardId,
      contactEmail: draft.email,
      contactPhone: draft.phone,
      contactWebsite: draft.website,
      contactLinkedin: draft.linkedin,
      visibleContactFields: CardVisibilityHelper.visibleFrontContactKeys(draft),
    );
  }
}
