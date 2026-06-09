import 'package:flutter/material.dart';

import '../../../../core/widgets/organisms/flippable_person_card.dart';
import '../../domain/entities/saved_card.dart';
import '../../domain/entities/saved_card_origin.dart';
import 'saved_card_origin_badge.dart';
import 'saved_cards_physical_photo_preview.dart';

class SavedCardsSavedCardPreview extends StatelessWidget {
  const SavedCardsSavedCardPreview({
    super.key,
    required this.card,
    this.onTap,
    this.heroTag,
    this.wrapHero = false,
    this.onEditNote,
  });

  final SavedCard card;
  final VoidCallback? onTap;
  final String? heroTag;
  final bool wrapHero;
  final VoidCallback? onEditNote;

  @override
  Widget build(BuildContext context) {
    final displayName = card.displayName?.trim().isEmpty ?? true
        ? 'Kart ${card.cardId}'
        : card.displayName!;
    final companyName = card.company?.trim();

    final frontEntries = <({String label, String value})>[
      if (card.title != null && card.title!.trim().isNotEmpty)
        (label: 'Ünvan', value: card.title!.trim()),
      if (card.email != null && card.email!.trim().isNotEmpty)
        (label: 'E-posta', value: card.email!.trim()),
      if (card.phone != null && card.phone!.trim().isNotEmpty)
        (label: 'Telefon', value: card.phone!.trim()),
    ];

    final backEntries = <({String label, String value})>[
      if (card.about != null && card.about!.trim().isNotEmpty)
        (label: 'Notlar', value: card.about!.trim()),
    ];

    final hasNote = card.about != null && card.about!.trim().isNotEmpty;
    final frontPhoto = card.frontImagePath?.trim();
    final hasPhysicalPhoto = frontPhoto != null && frontPhoto.isNotEmpty;

    final Widget cardWidget = hasPhysicalPhoto
        ? SavedCardsPhysicalPhotoPreview(
            frontImagePath: frontPhoto,
            backImagePath: card.backImagePath,
            onTap: onTap,
          )
        : FlippablePersonCard(
            title: displayName,
            titleSecondary: companyName,
            photoUrl: card.photoUrl,
            frontEntries: frontEntries,
            backEntries: backEntries,
            emptyMessage: 'Kart bilgisi yok',
            backEmptyMessage: 'Bu kisi icin not bulunmuyor.',
            backEmptyActionLabel: 'Not ekle',
            onBackEmptyActionTap: onEditNote,
            onBackEditTap: hasNote ? onEditNote : null,
            onTap: onTap,
          );

    final previewWithBadge = _SavedCardPreviewWithBadge(
      cardWidget: cardWidget,
      origin: card.origin,
    );

    if (!wrapHero || heroTag == null) return previewWithBadge;

    return Hero(
      tag: heroTag!,
      child: Material(
        color: Colors.transparent,
        child: previewWithBadge,
      ),
    );
  }
}

class _SavedCardPreviewWithBadge extends StatelessWidget {
  const _SavedCardPreviewWithBadge({
    required this.cardWidget,
    required this.origin,
  });

  final Widget cardWidget;
  final SavedCardOrigin origin;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        cardWidget,
        Positioned(
          top: 10,
          left: 10,
          child: SavedCardOriginBadge(origin: origin, compact: true),
        ),
      ],
    );
  }
}
