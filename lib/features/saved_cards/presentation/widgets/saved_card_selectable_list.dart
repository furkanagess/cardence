import 'package:flutter/material.dart';

import '../../domain/entities/saved_card.dart';
import 'saved_card_list_tile.dart';

/// Kaydedilen kartlar listesi görünümünde çoklu seçim.
class SavedCardSelectableList extends StatelessWidget {
  const SavedCardSelectableList({
    super.key,
    required this.cards,
    required this.selectedIds,
    required this.onToggle,
    this.controller,
    this.padding = const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
  });

  final List<SavedCard> cards;
  final Set<String> selectedIds;
  final void Function(String cardId) onToggle;
  final ScrollController? controller;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (cards.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
        child: Text(
          'Henüz kaydedilmiş kart yok. Kaydedilen Kartlar sekmesinden QR ile kart ekleyebilirsiniz.',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }

    return ListView.builder(
      controller: controller,
      padding: padding,
      itemCount: cards.length,
      itemBuilder: (context, index) {
        final card = cards[index];
        return SavedCardListTile(
          card: card,
          selectable: true,
          selected: selectedIds.contains(card.cardId),
          onTap: () => onToggle(card.cardId),
        );
      },
    );
  }
}
