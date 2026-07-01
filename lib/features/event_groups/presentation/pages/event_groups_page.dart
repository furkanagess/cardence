import 'package:flutter/material.dart';
import '../../../../core/l10n/app_l10n.dart';
import '../../../../core/l10n/l10n_extensions.dart';
import '../../../../core/theme/app_colors.dart';
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
import '../../domain/entities/event_group_invitation.dart';
import '../helpers/event_group_meta_formatter.dart';
import '../widgets/create_event_group_sheet.dart';
import '../../../../core/location/country_location_data_cache.dart';
import '../widgets/event_group_cover_thumbnail.dart';
import '../widgets/event_group_invitation_card.dart';
import '../widgets/event_groups_loading_shimmer.dart';
import '../widgets/event_groups_draggable_fab.dart';
import '../../domain/entities/event_group_create_input.dart';
import '../../domain/usecases/get_event_groups.dart';
import '../../domain/usecases/get_event_group_invitations.dart';
import '../../domain/usecases/accept_event_group_invitation.dart';
import '../../domain/usecases/reject_event_group_invitation.dart';
import '../../domain/usecases/create_event_group.dart';
import '../../domain/usecases/update_event_group.dart';
import '../../domain/usecases/invite_event_group_cards_by_card_id.dart';
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
    required this.getEventGroupInvitations,
    required this.acceptEventGroupInvitation,
    required this.rejectEventGroupInvitation,
    required this.createEventGroup,
    required this.updateEventGroup,
    required this.inviteEventGroupCardsByCardId,
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
  final GetEventGroupInvitations getEventGroupInvitations;
  final AcceptEventGroupInvitation acceptEventGroupInvitation;
  final RejectEventGroupInvitation rejectEventGroupInvitation;
  final CreateEventGroup createEventGroup;
  final UpdateEventGroup updateEventGroup;
  final InviteEventGroupCardsByCardId inviteEventGroupCardsByCardId;
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
  List<EventGroupInvitation> _invitations = [];
  bool _loading = true;
  bool _creatingGroup = false;
  String? _respondingInvitationId;

  static const double _contentBottomInset = 128;

  @override
  void initState() {
    super.initState();
    CountryLocationDataCache.warmUp();
    _loadGroups();
  }

  Future<void> _loadGroups() async {
    setState(() => _loading = true);
    try {
      final groups = await widget.getEventGroups();
      if (!mounted) return;
      setState(() {
        _groups = groups;
        _loading = false;
      });
    } on AuthApiException {
      if (!mounted) return;
      setState(() => _loading = false);
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }

    try {
      final invitations = await widget.getEventGroupInvitations();
      if (!mounted) return;
      setState(() => _invitations = invitations);
    } catch (_) {
      // Davet endpoint'i henüz production'da olmayabilir; grup listesi etkilenmesin.
    }
  }

  Future<void> _respondToInvitation({
    required EventGroupInvitation invitation,
    required bool accept,
  }) async {
    if (_respondingInvitationId != null) return;

    setState(() => _respondingInvitationId = invitation.id);
    try {
      if (accept) {
        await widget.acceptEventGroupInvitation(invitation.id);
      } else {
        await widget.rejectEventGroupInvitation(invitation.id);
      }
      if (!mounted) return;
      await _loadGroups();
    } on AuthApiException {
      if (!mounted) return;
    } finally {
      if (mounted) setState(() => _respondingInvitationId = null);
    }
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
      initialPickableCards: savedCardsCubit.state.cards,
    );
    if (!mounted || result == null) return;

    setState(() => _creatingGroup = true);
    try {
      EventGroup newGroup;
      try {
        newGroup = await widget.createEventGroup(
          EventGroupCreateInput(
            name: result.name,
            location: result.location,
            startAt: result.startAt,
            endAt: result.endAt,
            photoFilePath: result.photoFilePath,
            invitedCardIds: result.invitedCardIds,
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
        return;
      }

      if (result.selectedCardIds.isNotEmpty) {
        final allCards = savedCardsCubit.state.cards;
        await widget.linkSavedCardsToEventGroup(
          groupId: newGroup.id,
          allCards: allCards,
          cardIdsToAdd: result.selectedCardIds.toList(),
        );
      }

      final validInvitedCount =
          result.invitedCardIds.length - newGroup.invalidCardIds.length;
      if (result.selectedCardIds.isNotEmpty || validInvitedCount > 0) {
        if (mounted) {
          await savedCardsCubit.refreshAll();
        }
      }

      if (!mounted) return;
      await _loadGroups();
      if (!mounted) return;
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

    if (_groups.isEmpty && _invitations.isEmpty) {
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

    final activeGroups = _groups
        .where((group) => group.status != EventGroupStatus.ended)
        .toList();
    final endedGroups = _groups
        .where((group) => group.status == EventGroupStatus.ended)
        .toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, _contentBottomInset),
      children: [
        if (_invitations.isNotEmpty) ...[
          _buildInvitationsSection(context),
          if (activeGroups.isNotEmpty || endedGroups.isNotEmpty)
            const SizedBox(height: 16),
        ],
        if (activeGroups.isNotEmpty)
          _buildSection(
            context,
            title: context.l10n.eventActiveSection,
            groups: activeGroups,
            savedCards: savedCards,
          ),
        if (endedGroups.isNotEmpty) ...[
          if (activeGroups.isNotEmpty) const SizedBox(height: 12),
          _buildSection(
            context,
            title: context.l10n.eventEndedSection,
            groups: endedGroups,
            savedCards: savedCards,
          ),
        ],
      ],
    );
  }

  Widget _buildInvitationsSection(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Text(
            context.l10n.eventInvitationsSection,
            style: textTheme.titleSmall?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        ..._invitations.map(
          (invitation) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: EventGroupInvitationCard(
              invitation: invitation,
              isResponding: _respondingInvitationId == invitation.id,
              onAccept: () => _respondToInvitation(
                invitation: invitation,
                accept: true,
              ),
              onReject: () => _respondToInvitation(
                invitation: invitation,
                accept: false,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required List<EventGroup> groups,
    required List<SavedCard> savedCards,
  }) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Text(
            title,
            style: textTheme.titleSmall?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        ...groups.map(
          (group) => _buildGroupTile(context, group, savedCards),
        ),
      ],
    );
  }

  Widget _buildGroupTile(
    BuildContext context,
    EventGroup group,
    List<SavedCard> savedCards,
  ) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
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
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              group.name,
                              style: textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: colorScheme.onSurface,
                              ),
                            ),
                          ),
                          _EventStatusBadge(status: group.status),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
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
  }

  void _openDetail(EventGroup group) {
    Navigator.of(context)
        .push(
          MaterialPageRoute<void>(
            builder: (context) => EventGroupDetailPage(
              group: group,
              getEventGroups: widget.getEventGroups,
              updateEventGroup: widget.updateEventGroup,
              inviteEventGroupCardsByCardId:
                  widget.inviteEventGroupCardsByCardId,
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

class _EventStatusBadge extends StatelessWidget {
  const _EventStatusBadge({required this.status});

  final EventGroupStatus status;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final color = switch (status) {
      EventGroupStatus.ongoing => AppColors.success,
      EventGroupStatus.upcoming => theme.colorScheme.primary,
      EventGroupStatus.ended => theme.colorScheme.onSurfaceVariant,
    };

    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.18 : 0.1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Text(
          _statusLabel(context, status),
          style: theme.textTheme.labelSmall?.copyWith(
            color: color,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  String _statusLabel(BuildContext context, EventGroupStatus status) {
    return switch (status) {
      EventGroupStatus.upcoming => context.l10n.eventStatusUpcoming,
      EventGroupStatus.ongoing => context.l10n.eventStatusOngoing,
      EventGroupStatus.ended => context.l10n.eventStatusEnded,
    };
  }
}
