import 'package:flutter/material.dart';

import '../../../../core/widgets/organisms/flippable_person_card.dart';
import '../../domain/entities/saved_card.dart';
import '../../domain/extensions/saved_card_preview_colors.dart';
import '../../domain/extensions/saved_card_preview_entries.dart';

class SavedCardsSavedCardPreview extends StatelessWidget {
  const SavedCardsSavedCardPreview({
    super.key,
    required this.card,
    this.onDoubleTap,
    this.heroTag,
    this.wrapHero = false,
  });

  final SavedCard card;
  final VoidCallback? onDoubleTap;
  final String? heroTag;
  final bool wrapHero;

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

    final cardWidget = FlippablePersonCard(
      title: displayName,
      titleSecondary: companyName,
      jobTitle: card.title?.trim(),
      photoUrl: card.photoUrl,
      accentColor: card.previewAccentColor,
      backgroundColor: card.previewBackgroundColor,
      frontEntries: const [],
      backEntries: card.backAboutEntries,
      emptyMessage: 'Kart bilgisi yok',
      cardId: card.cardId,
      onDoubleTap: onDoubleTap,
      contactEmail: card.email,
      contactPhone: card.phone,
      contactWebsite: card.website,
      contactLinkedin: card.linkedin,
      visibleContactFields: visibleContacts,
      showPremiumBadge: card.isOwnerPremium,
    );

    if (!wrapHero || heroTag == null) return cardWidget;

    return Hero(
      tag: heroTag!,
      child: Material(
        color: Colors.transparent,
        child: cardWidget,
      ),
    );
  }
}
