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
import '../../domain/entities/event_group_invitation.dart';
import '../pages/create_event_group_page.dart';
import '../../../../core/location/country_location_data_cache.dart';
import '../widgets/event_group_list_card.dart';
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

    final result = await CreateEventGroupPage.push(
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
            description: result.description,
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
    final screenWidth = MediaQuery.sizeOf(context).width;
    const horizontalPeek = 24.0;
    const listHorizontalPadding = 20.0;
    final cardWidth = screenWidth - (listHorizontalPadding * 2) - horizontalPeek;

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
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          clipBehavior: Clip.none,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var index = 0; index < _invitations.length; index++) ...[
                if (index > 0) const SizedBox(width: 12),
                SizedBox(
                  width: cardWidth,
                  child: EventGroupInvitationCard(
                    invitation: _invitations[index],
                    isResponding:
                        _respondingInvitationId == _invitations[index].id,
                    onAccept: () => _respondToInvitation(
                      invitation: _invitations[index],
                      accept: true,
                    ),
                    onReject: () => _respondToInvitation(
                      invitation: _invitations[index],
                      accept: false,
                    ),
                  ),
                ),
              ],
            ],
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
          (group) => Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: EventGroupListCard(
              group: group,
              linkedCardCount: _savedCardCountForGroup(group.id, savedCards),
              onTap: () => _openDetail(group),
            ),
          ),
        ),
      ],
    );
  }

  void _openDetail(EventGroup group) {
    final groupsPageContext = context;
    Navigator.of(context)
        .push(
          MaterialPageRoute<void>(
            builder: (_) => EventGroupDetailPage(
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
              onSavedCardsChanged: () =>
                  groupsPageContext.read<SavedCardsCubit>().refreshAll(),
            ),
          ),
        )
        .then((_) => _loadGroups());
  }
}
