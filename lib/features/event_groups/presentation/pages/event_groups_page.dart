import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../saved_cards/presentation/cubit/saved_cards_cubit.dart';
import '../../../saved_cards/presentation/cubit/saved_cards_state.dart';
import '../../../saved_cards/presentation/saved_cards_catalog.dart';
import '../../domain/entities/event_group.dart';
import '../widgets/create_event_group_sheet.dart';
import '../../domain/usecases/get_event_groups.dart';
import '../../domain/usecases/create_event_group.dart';
import '../../domain/usecases/delete_event_group.dart';
import '../../domain/usecases/link_event_group_cards.dart';
import '../../../saved_cards/domain/entities/saved_card.dart';
import '../../../saved_cards/domain/usecases/delete_saved_card.dart';
import '../../../saved_cards/domain/usecases/get_saved_cards.dart';
import '../../../saved_cards/domain/usecases/save_saved_card.dart';
import 'event_group_detail_page.dart';

/// Etkinlik grupları listesi; tıklanınca o gruptaki kayıtlı kartlar detayda listelenir.
class EventGroupsPage extends StatefulWidget {
  const EventGroupsPage({
    super.key,
    required this.getEventGroups,
    required this.createEventGroup,
    required this.deleteEventGroup,
    required this.linkEventGroupCards,
    required this.getSavedCards,
    required this.saveSavedCard,
    required this.deleteSavedCard,
    this.createGroupTrigger = 0,
  });

  final GetEventGroups getEventGroups;
  final CreateEventGroup createEventGroup;
  final DeleteEventGroup deleteEventGroup;
  final LinkEventGroupCards linkEventGroupCards;
  final GetSavedCards getSavedCards;
  final SaveSavedCard saveSavedCard;
  final DeleteSavedCard deleteSavedCard;
  final int createGroupTrigger;

  @override
  State<EventGroupsPage> createState() => _EventGroupsPageState();
}

class _EventGroupsPageState extends State<EventGroupsPage> {
  List<EventGroup> _groups = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadGroups();
  }

  Future<void> _loadGroups() async {
    setState(() => _loading = true);
    final groups = await widget.getEventGroups();
    if (!mounted) return;
    setState(() {
      _groups = groups;
      _loading = false;
    });
  }

  int _savedCardCountForGroup(String groupId, List<SavedCard> savedCards) {
    return savedCards
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

    final savedCardsCubit = context.read<SavedCardsCubit>();
    final newGroup = await widget.createEventGroup(result.name);

    if (result.selectedCardIds.isNotEmpty) {
      await widget.linkEventGroupCards(
        groupId: newGroup.id,
        cardIds: result.selectedCardIds.toList(),
      );
      if (mounted) {
        await savedCardsCubit.refreshAll();
      }
    }

    if (!mounted) return;
    await _loadGroups();
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
    return BlocBuilder<SavedCardsCubit, SavedCardsState>(
      builder: (context, savedState) {
        final savedCards = SavedCardsCatalog.displayCards(savedState.cards);
        return _buildContent(context, savedCards);
      },
    );
  }

  Widget _buildContent(BuildContext context, List<SavedCard> savedCards) {
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
        final cardCount = _savedCardCountForGroup(group.id, savedCards);
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
              deleteEventGroup: widget.deleteEventGroup,
              linkEventGroupCards: widget.linkEventGroupCards,
              getSavedCards: widget.getSavedCards,
              saveSavedCard: widget.saveSavedCard,
              deleteSavedCard: widget.deleteSavedCard,
            ),
          ),
        )
        .then((_) => _loadGroups());
  }
}
