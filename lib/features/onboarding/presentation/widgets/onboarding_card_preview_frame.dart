import 'package:flutter/material.dart';

import '../../../../core/l10n/l10n_extensions.dart';
import '../../../../core/widgets/organisms/flippable_person_card.dart';
import '../../domain/entities/onboarding_card_draft.dart';
import '../../domain/helpers/onboarding_draft_helper.dart';
import '../onboarding_preview_helpers.dart';

/// Onboarding adımları ve profil dahil tüm ekranlarda aynı kart önizlemesi.
class OnboardingCardPreviewFrame extends StatelessWidget {
  const OnboardingCardPreviewFrame({
    super.key,
    required this.draft,
    this.onTap,
    this.onDoubleTap,
    this.flipOnTouch = false,
    this.emptyMessage = 'Alanlar doldukça görünür',
    this.maxWidth = 420,
    this.normalizeForDisplay = false,
    this.showPremiumBadge = false,
    this.contactFieldsTappable = true,
  });

  final OnboardingCardDraft draft;
  final VoidCallback? onTap;
  final VoidCallback? onDoubleTap;
  final bool flipOnTouch;
  final String emptyMessage;
  final double maxWidth;

  /// Kayıtlı kartlarda görünürlük / cardId normalizasyonu uygula.
  final bool normalizeForDisplay;

  /// Premium kullanıcının kendi kartında yıldız rozeti.
  final bool showPremiumBadge;

  /// false: ön yüzdeki e-posta/telefon vb. iletişim alanları tıklanamaz.
  final bool contactFieldsTappable;

  static double heightForWidth(double width) {
    return width / FlippablePersonCard.cardAspectRatio;
  }

  OnboardingCardDraft _displayDraft() {
    if (!normalizeForDisplay) return draft;
    return OnboardingDraftHelper.forPreview(draft);
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: OnboardingPreviewHelpers.preview(
          context.l10n,
          _displayDraft(),
          flipOnTouch: flipOnTouch,
          onTap: onTap,
          onDoubleTap: onDoubleTap,
          emptyMessage: emptyMessage,
          showPremiumBadge: showPremiumBadge,
          contactFieldsTappable: contactFieldsTappable,
        ),
      ),
    );
  }
}
