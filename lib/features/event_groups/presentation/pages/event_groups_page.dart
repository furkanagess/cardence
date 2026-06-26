import 'package:flutter/material.dart';
import '../../../../core/l10n/app_l10n.dart';
import '../../../../core/l10n/l10n_extensions.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/network/auth_api_exception.dart';
import '../../../plans/presentation/cubit/plan_cubit.dart';
import '../../../plans/presentation/cubit/plan_state.dart';
import '../../../saved_cards/presentation/cubit/saved_cards_cubit.dart';
import '../../../saved_cards/presentation/cubit/saved_cards_state.dart';
import '../../../saved_cards/presentation/wallet_paywall_flow.dart';
import '../../../subscriptions/domain/usecases/restore_wallet_purchases.dart';
import '../../../network_graph/domain/usecases/get_network_graph.dart';
import '../../../network_graph/domain/usecases/get_network_graph_path.dart';
import '../../domain/entities/event_group.dart';
import '../helpers/event_group_meta_formatter.dart';
import '../widgets/create_event_group_sheet.dart';
import '../widgets/event_group_cover_thumbnail.dart';
import '../widgets/event_groups_loading_shimmer.dart';
import '../widgets/event_groups_draggable_fab.dart';
import '../../domain/entities/event_group_create_input.dart';
import '../../domain/usecases/get_event_groups.dart';
import '../../domain/usecases/create_event_group.dart';
import '../../domain/usecases/delete_event_group.dart';
import '../../../saved_cards/domain/usecases/link_saved_cards_to_event_group.dart';
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
    required this.linkSavedCardsToEventGroup,
    required this.getSavedCards,
    required this.saveSavedCard,
    required this.deleteSavedCard,
    required this.restoreWalletPurchases,
    required this.getNetworkGraph,
    required this.getNetworkGraphPath,
  });

  final GetEventGroups getEventGroups;
  final CreateEventGroup createEventGroup;
  final DeleteEventGroup deleteEventGroup;
  final LinkSavedCardsToEventGroup linkSavedCardsToEventGroup;
  final GetSavedCards getSavedCards;
  final SaveSavedCard saveSavedCard;
  final DeleteSavedCard deleteSavedCard;
  final RestoreWalletPurchases restoreWalletPurchases;
  final GetNetworkGraph getNetworkGraph;
  final GetNetworkGraphPath getNetworkGraphPath;

  @override
  State<EventGroupsPage> createState() => _EventGroupsPageState();
}

class _EventGroupsPageState extends State<EventGroupsPage> {
  List<EventGroup> _groups = [];
  bool _loading = true;
  bool _creatingGroup = false;

  static const double _contentBottomInset = 128;

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

  bool _canAddGroupFromPlan(PlanState planState) {
    final maxEventGroups = planState.entitlements?.limits.maxEventGroups;
    return maxEventGroups == null || _groups.length < maxEventGroups;
  }

  Future<void> _createNewEventGroup() async {
    if (_creatingGroup) return;
    setState(() => _creatingGroup = true);

    try {
      final savedCardsCubit = context.read<SavedCardsCubit>();
      final planCubit = context.read<PlanCubit>();
      final planAllowsGroup = _canAddGroupFromPlan(planCubit.state);
      final quota = savedCardsCubit.state.quota;
      if (!planAllowsGroup || !quota.canAddEventGroup) {
        await WalletPaywallFlow.show(
          context,
          cubit: savedCardsCubit,
        );
        if (mounted) {
          await planCubit.refresh();
        }
        return;
      }

      final result = await CreateEventGroupSheet.show(
        context,
        existingNames: _groups.map((g) => g.name).toList(),
        getSavedCards: widget.getSavedCards,
      );
      if (!mounted || result == null) return;

      EventGroup newGroup;
      try {
        newGroup = await widget.createEventGroup(
          EventGroupCreateInput(
            name: result.name,
            location: result.location,
            eventDate: result.eventDate,
            photoFilePath: result.photoFilePath,
          ),
        );
      } on AuthApiException catch (e) {
        if (!mounted) return;
        if (e.errorCode == 'PREMIUM_REQUIRED' ||
            e.errorCode == 'PLAN_LIMIT_REACHED') {
          await WalletPaywallFlow.show(
            context,
            cubit: savedCardsCubit,
          );
          if (mounted) {
            await context.read<PlanCubit>().refresh();
          }
          return;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      if (result.selectedCardIds.isNotEmpty) {
        final allCards = savedCardsCubit.state.cards;
        await widget.linkSavedCardsToEventGroup(
          groupId: newGroup.id,
          allCards: allCards,
          cardIdsToAdd: result.selectedCardIds.toList(),
        );
        if (mounted) {
          await savedCardsCubit.refreshAll();
        }
      }

      if (!mounted) return;
      await _loadGroups();
      if (!mounted) return;

      final cardCount = result.selectedCardIds.length;
      final l10n = context.l10n;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            cardCount == 0
                ? AppL10n.eventGroupCreatedMessage(l10n, result.name)
                : AppL10n.eventGroupCreatedWithCardsMessage(l10n, result.name, cardCount),
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _creatingGroup = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlanCubit, PlanState>(
      builder: (context, planState) {
        return BlocBuilder<SavedCardsCubit, SavedCardsState>(
          builder: (context, savedState) {
            final savedCards = savedState.cards;
            final canAddGroup = _canAddGroupFromPlan(planState) &&
                savedState.quota.canAddEventGroup;

            return Stack(
              children: [
                Positioned.fill(
                  child: _buildContent(context, savedCards),
                ),
                Positioned.fill(
                  child: EventGroupsDraggableFab(
                    canAddGroup: canAddGroup,
                    onPressed: _createNewEventGroup,
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildContent(BuildContext context, List<SavedCard> savedCards) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    if (_loading) {
      return const EventGroupsLoadingShimmer();
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
                AppL10n.henzEtkinlikGrubuYok(context.l10n),
                style: textTheme.titleMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                AppL10n.saAlttakiIleYeniEtkinlik(context.l10n),
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
      padding: const EdgeInsets.fromLTRB(20, 16, 20, _contentBottomInset),
      itemCount: _groups.length,
      itemBuilder: (context, index) {
        final group = _groups[index];
        final cardCount = _savedCardCountForGroup(group.id, savedCards);
        final meta = EventGroupMetaFormatter.summaryFor(group);
        final l10n = context.l10n;
        final subtitle = [
          if (meta != null) meta,
          if (cardCount == 0)
            AppL10n.noCardsInGroup(l10n)
          else
            AppL10n.savedCardsCount(l10n, cardCount),
        ].join(' · ');
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
                    SizedBox(
                      width: 44,
                      height: 44,
                      child: EventGroupCoverThumbnail(
                        photoUrl: group.photoUrl,
                        size: 44,
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
                            subtitle,
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
              linkSavedCardsToEventGroup: widget.linkSavedCardsToEventGroup,
              getSavedCards: widget.getSavedCards,
              saveSavedCard: widget.saveSavedCard,
              deleteSavedCard: widget.deleteSavedCard,
              getNetworkGraph: widget.getNetworkGraph,
              getNetworkGraphPath: widget.getNetworkGraphPath,
            ),
          ),
        )
        .then((_) => _loadGroups());
  }
}
