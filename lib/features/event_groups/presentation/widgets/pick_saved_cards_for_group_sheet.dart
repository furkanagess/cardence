import 'package:flutter/material.dart';
import '../../../../core/l10n/l10n_extensions.dart';

import '../../../../core/widgets/atoms/custom_button.dart';
import '../../../saved_cards/domain/entities/saved_card.dart';
import '../../../saved_cards/presentation/widgets/saved_card_selectable_list.dart';

/// Kaydedilen kartlardan etkinlik grubuna eklenecek kartları seçtirir.
class PickSavedCardsForGroupSheet extends StatefulWidget {
  const PickSavedCardsForGroupSheet({
    super.key,
    required this.cards,
    required this.eventGroupId,
    required this.eventGroupName,
    this.addOnly = false,
  });

  final List<SavedCard> cards;
  final String eventGroupId;
  final String eventGroupName;
  final bool addOnly;

  static Future<Set<String>?> show(
    BuildContext context, {
    required List<SavedCard> cards,
    required String eventGroupId,
    required String eventGroupName,
    bool addOnly = false,
  }) {
    return showModalBottomSheet<Set<String>>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      useSafeArea: true,
      builder: (context) => PickSavedCardsForGroupSheet(
        cards: cards,
        eventGroupId: eventGroupId,
        eventGroupName: eventGroupName,
        addOnly: addOnly,
      ),
    );
  }

  @override
  State<PickSavedCardsForGroupSheet> createState() =>
      _PickSavedCardsForGroupSheetState();
}

class _PickSavedCardsForGroupSheetState
    extends State<PickSavedCardsForGroupSheet> {
  late final Set<String> _selectedIds;

  @override
  void initState() {
    super.initState();
    _selectedIds = widget.addOnly
        ? {}
        : widget.cards
            .where((c) => c.linkedEventGroupIds.contains(widget.eventGroupId))
            .map((c) => c.cardId)
            .toSet();
  }

  void _toggleSelection(String cardId) {
    setState(() {
      if (_selectedIds.contains(cardId)) {
        _selectedIds.remove(cardId);
      } else {
        _selectedIds.add(cardId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final sheetHeight = MediaQuery.sizeOf(context).height * 0.75;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: SizedBox(
        height: sheetHeight,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.kaydedilenKartlardanSe,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${widget.eventGroupName} grubuna eklenecek kayıtlı kartları seçin.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SavedCardSelectableList(
                cards: widget.cards,
                selectedIds: _selectedIds,
                onToggle: _toggleSelection,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: CustomButton(
                label: _selectedIds.isEmpty
                    ? 'Kartları gruba ekle'
                    : '${_selectedIds.length} kartı gruba ekle',
                onPressed: widget.cards.isEmpty || _selectedIds.isEmpty
                    ? null
                    : () => Navigator.of(context).pop(_selectedIds),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
