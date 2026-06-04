import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../saved_cards/presentation/saved_cards_catalog.dart';
import '../../domain/entities/event_group.dart';
import '../widgets/create_event_group_sheet.dart';
import '../../domain/usecases/get_event_groups.dart';
import '../../domain/usecases/save_event_groups.dart';
import '../../../saved_cards/domain/entities/saved_card.dart';
import '../../../saved_cards/domain/usecases/get_saved_cards.dart';
import '../../../saved_cards/domain/usecases/save_saved_card.dart';
import 'event_group_detail_page.dart';

/// Etkinlik grupları listesi; tıklanınca o gruptaki kayıtlı kartlar detayda listelenir.
class EventGroupsPage extends StatefulWidget {
  const EventGroupsPage({
    super.key,
    required this.getEventGroups,
    required this.saveEventGroups,
    required this.getSavedCards,
    required this.saveSavedCard,
    this.createGroupTrigger = 0,
  });

  final GetEventGroups getEventGroups;
  final SaveEventGroups saveEventGroups;
  final GetSavedCards getSavedCards;
  final SaveSavedCard saveSavedCard;
  final int createGroupTrigger;

  @override
  State<EventGroupsPage> createState() => _EventGroupsPageState();
}

class _EventGroupsPageState extends State<EventGroupsPage> {
  List<EventGroup> _groups = [];
  List<SavedCard> _savedCards = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final results = await Future.wait([
      widget.getEventGroups(),
      widget.getSavedCards(),
    ]);
    if (!mounted) return;
    setState(() {
      _groups = results[0] as List<EventGroup>;
      _savedCards = results[1] as List<SavedCard>;
      _loading = false;
    });
  }

  int _savedCardCountForGroup(String groupId) {
    return _savedCards
        .where((c) => c.linkedEventGroupIds.contains(groupId))
        .length;
  }

  Future<void> _createNewEventGroup() async {
    final result = await CreateEventGroupSheet.show(
      context,
      existingNames: _groups.map((g) => g.name).toList(),
      getSavedCards: widget.getSavedCards,
    );
    if (!mounted || result == null) return;

    final newGroup = EventGroup(id: const Uuid().v4(), name: result.name);
    final updatedList = List<EventGroup>.from(_groups)..add(newGroup);
    await widget.saveEventGroups(updatedList);

    if (result.selectedCardIds.isNotEmpty) {
      final persisted = await widget.getSavedCards();
      final pickable = SavedCardsCatalog.displayCards(persisted);
      for (final card in pickable) {
        if (!result.selectedCardIds.contains(card.cardId)) continue;
        if (card.linkedEventGroupIds.contains(newGroup.id)) continue;
        final ids = List<String>.from(card.linkedEventGroupIds)
          ..add(newGroup.id);
        await widget.saveSavedCard(card.copyWith(linkedEventGroupIds: ids));
      }
    }

    if (!mounted) return;
    await _load();
    if (!mounted) return;

    final cardCount = result.selectedCardIds.length;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          cardCount == 0
              ? '"${result.name}" etkinlik grubu oluşturuldu'
              : '"${result.name}" grubu $cardCount kartla oluşturuldu',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  void didUpdateWidget(covariant EventGroupsPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.createGroupTrigger != widget.createGroupTrigger) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _createNewEventGroup();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_groups.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.event_note_rounded,
                size: 64,
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 16),
              Text(
                'Henüz etkinlik grubu yok',
                style: textTheme.titleMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Sol üstteki + ile yeni etkinlik grubu oluşturabilirsiniz.',
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      itemCount: _groups.length,
      itemBuilder: (context, index) {
        final group = _groups[index];
        final cardCount = _savedCardCountForGroup(group.id);
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Material(
            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => _openDetail(group),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.event_rounded,
                        color: AppColors.primary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            group.name,
                            style: textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            cardCount == 0
                                ? 'Bu grupta kart yok'
                                : '$cardCount kayıtlı kart',
                            style: textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: colorScheme.onSurfaceVariant,
                      size: 24,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _openDetail(EventGroup group) {
    Navigator.of(context)
        .push(
          MaterialPageRoute<void>(
            builder: (context) => EventGroupDetailPage(
              group: group,
              getEventGroups: widget.getEventGroups,
              saveEventGroups: widget.saveEventGroups,
              getSavedCards: widget.getSavedCards,
              saveSavedCard: widget.saveSavedCard,
            ),
          ),
        )
        .then((_) => _load());
  }
}
