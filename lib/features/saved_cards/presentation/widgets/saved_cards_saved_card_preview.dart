import 'package:flutter/material.dart';
import '../../../../core/l10n/l10n_extensions.dart';

import '../../../../core/widgets/organisms/flippable_person_card.dart';
import '../../domain/entities/saved_card.dart';
import '../../domain/extensions/saved_card_preview_colors.dart';

class SavedCardsSavedCardPreview extends StatelessWidget {
  const SavedCardsSavedCardPreview({
    super.key,
    required this.card,
    this.onDetailTap,
    this.onTap,
    this.heroTag,
    this.showActionStrip = true,
  });

  final SavedCard card;
  final VoidCallback? onDetailTap;
  final VoidCallback? onTap;
  final String? heroTag;
  final bool showActionStrip;

  @override
  Widget build(BuildContext context) {
    final displayName = card.displayName?.trim().isEmpty ?? true
        ? 'Kart ${card.cardId}'
        : card.displayName!;
    final companyName = card.company?.trim();

    final visibleContacts = <String>[
      if (card.email != null && card.email!.trim().isNotEmpty) 'email',
      if (card.phone != null && card.phone!.trim().isNotEmpty) 'phone',
      if (card.linkedin != null && card.linkedin!.trim().isNotEmpty) 'linkedin',
      if (card.website != null && card.website!.trim().isNotEmpty) 'website',
    ];

    // cardId anahtarı odak/Hero değişiminde State'i korur; foto yeniden
    // yüklenmez.
    final cardWidget = FlippablePersonCard(
      key: ValueKey('saved-card-preview-${card.cardId}'),
      title: displayName,
      titleSecondary: companyName,
      jobTitle: card.title?.trim(),
      photoUrl: card.photoUrl,
      accentColor: card.previewAccentColor,
      backgroundColor: card.previewBackgroundColor,
      frontEntries: const [],
      emptyMessage: context.l10n.kartBilgisiYok,
      cardId: card.cardId,
      onDetailTap: onDetailTap ?? onTap,
      showActionStrip: showActionStrip,
      contactFieldsTappable: true,
      contactEmail: card.email,
      contactPhone: card.phone,
      contactWebsite: card.website,
      contactLinkedin: card.linkedin,
      visibleContactFields: visibleContacts,
      showPremiumBadge: card.isOwnerPremium,
      heroTag: heroTag,
    );

    return cardWidget;
  }
}
