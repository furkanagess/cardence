import 'package:flutter/material.dart';

import '../../../../core/widgets/organisms/flippable_person_card.dart';
import '../../domain/entities/saved_card.dart';
import '../../domain/entities/saved_card_origin.dart';
import '../../domain/extensions/saved_card_preview_colors.dart';
import '../../domain/extensions/saved_card_preview_entries.dart';
import 'saved_card_origin_badge.dart';
import 'saved_cards_physical_photo_preview.dart';

class SavedCardsSavedCardPreview extends StatelessWidget {
  const SavedCardsSavedCardPreview({
    super.key,
    required this.card,
    this.onTap,
    this.heroTag,
    this.wrapHero = false,
  });

  final SavedCard card;
  final VoidCallback? onTap;
  final String? heroTag;
  final bool wrapHero;

  @override
  Widget build(BuildContext context) {
    final displayName = card.displayName?.trim().isEmpty ?? true
        ? 'Kart ${card.cardId}'
        : card.displayName!;
    final companyName = card.company?.trim();

    final frontPhoto = card.frontImagePath?.trim();
    final hasPhysicalPhoto = frontPhoto != null && frontPhoto.isNotEmpty;

    final visibleContacts = <String>[
      if (card.email != null && card.email!.trim().isNotEmpty) 'email',
      if (card.phone != null && card.phone!.trim().isNotEmpty) 'phone',
      if (card.linkedin != null && card.linkedin!.trim().isNotEmpty) 'linkedin',
      if (card.website != null && card.website!.trim().isNotEmpty) 'website',
    ];

    final Widget cardWidget = hasPhysicalPhoto
        ? SavedCardsPhysicalPhotoPreview(
            frontImagePath: frontPhoto,
            backImagePath: card.backImagePath,
            onTap: onTap,
          )
        : FlippablePersonCard(
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
            onTap: onTap,
            showAppLogo: card.isCardenceLinked,
            contactEmail: card.email,
            contactPhone: card.phone,
            contactWebsite: card.website,
            contactLinkedin: card.linkedin,
            visibleContactFields: visibleContacts,
          );

    final previewWithOrigin = _SavedCardPreviewWithOrigin(
      cardWidget: cardWidget,
      origin: card.origin,
    );

    if (!wrapHero || heroTag == null) return previewWithOrigin;

    return Hero(
      tag: heroTag!,
      child: Material(
        color: Colors.transparent,
        child: previewWithOrigin,
      ),
    );
  }
}

class _SavedCardPreviewWithOrigin extends StatelessWidget {
  const _SavedCardPreviewWithOrigin({
    required this.cardWidget,
    required this.origin,
  });

  final Widget cardWidget;
  final SavedCardOrigin origin;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isManual = origin == SavedCardOrigin.manual;

    if (isManual) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: colorScheme.outlineVariant.withValues(alpha: 0.65),
                width: 1.25,
              ),
            ),
            child: cardWidget,
          ),
          const SizedBox(height: 8),
          const ManualEntryCaption(compact: true),
        ],
      );
    }

    return cardWidget;
  }
}
