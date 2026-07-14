import 'package:flutter/material.dart';
import '../../../../core/l10n/app_l10n.dart';
import '../../../../core/l10n/api_error_localizer.dart';
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
import '../helpers/create_event_group_submit_result.dart';
import '../../../../core/location/country_location_data_cache.dart';
import '../widgets/event_group_invitation_card.dart';
import '../widgets/event_groups_horizontal_section.dart';
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
import '../../domain/usecases/get_event_group_outbound_invitations.dart';
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
    required this.getEventGroupOutboundInvitations,
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
  final GetEventGroupOutboundInvitations getEventGroupOutboundInvitations;
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

    if (accept) {
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
          await savedCardsCubit.refreshAll();
        }
        return;
      }
    }

    setState(() => _respondingInvitationId = invitation.id);
    try {
      if (accept) {
        await widget.acceptEventGroupInvitation(invitation.id);
      } else {
        await widget.rejectEventGroupInvitation(invitation.id);
      }
      if (!mounted) return;
      await _loadGroups();
      if (mounted && accept) {
        await context.read<SavedCardsCubit>().refreshAll();
      }
    } on AuthApiException catch (e) {
      if (!mounted) return;
      if (accept &&
          (e.errorCode == 'PREMIUM_REQUIRED' ||
              e.errorCode == 'PLAN_LIMIT_REACHED')) {
        final savedCardsCubit = context.read<SavedCardsCubit>();
        await WalletPaywallFlow.show(
          context,
          cubit: savedCardsCubit,
        );
        if (mounted) {
          await context.read<PlanCubit>().refresh();
          await savedCardsCubit.refreshAll();
        }
      }
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

  Future<CreateEventGroupSubmitResult> _submitNewEventGroup(
    CreateEventGroupResult draft,
  ) async {
    final l10n = context.l10n;
    final savedCardsCubit = context.read<SavedCardsCubit>();

    try {
      final invitedCardIds = <String>{
        ...draft.invitedCardIds,
        ...draft.selectedCardIds,
      }.toList();

      final newGroup = await widget.createEventGroup(
        EventGroupCreateInput(
          name: draft.name,
          location: draft.location,
          startAt: draft.startAt,
          endAt: draft.endAt,
          description: draft.description,
          photoFilePath: draft.photoFilePath,
          invitedCardIds: invitedCardIds,
        ),
      );

      final validInvitedCount =
          invitedCardIds.length - newGroup.invalidCardIds.length;
      if (validInvitedCount > 0 && mounted) {
        await savedCardsCubit.refreshAll();
      }

      final successMessage = validInvitedCount > 0
          ? AppL10n.eventGroupCreatedWithCardsMessage(
              l10n,
              draft.name,
              validInvitedCount,
            )
          : AppL10n.eventGroupCreatedMessage(l10n, draft.name);

      return CreateEventGroupSubmitSuccess(
        successTitle: l10n.eventGroupCreatedSuccess,
        successMessage: successMessage,
      );
    } on AuthApiException catch (e) {
      if (e.errorCode == 'PREMIUM_REQUIRED' ||
          e.errorCode == 'PLAN_LIMIT_REACHED') {
        return const CreateEventGroupSubmitPaywallRequired();
      }
      return CreateEventGroupSubmitFailure(
        title: l10n.eventGroupCreateFailed,
        message: ApiErrorLocalizer.localizeException(l10n, e),
      );
    } catch (_) {
      return CreateEventGroupSubmitFailure(
        title: l10n.eventGroupCreateFailed,
        message: l10n.operationFailed,
      );
    }
  }

  Future<void> _createNewEventGroup() async {
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

    final outcome = await CreateEventGroupPage.push(
      context,
      existingNames: _groups.map((g) => g.name).toList(),
      getSavedCards: widget.getSavedCards,
      initialPickableCards: savedCardsCubit.state.cards,
      onSubmit: _submitNewEventGroup,
    );
    if (!mounted || outcome == null) return;

    if (outcome == CreateEventGroupPageOutcome.paywallRequired) {
      await WalletPaywallFlow.show(
        context,
        cubit: savedCardsCubit,
      );
      if (mounted) {
        await context.read<PlanCubit>().refresh();
      }
      return;
    }

    await _loadGroups();
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
                  child: _buildContent(
                    context,
                    savedCards,
                    canAcceptInvitations: canAddGroup,
                  ),
                ),
                EventGroupsDraggableFab(
                  canAddGroup: canAddGroup,
                  onPressed: _createNewEventGroup,
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildContent(
    BuildContext context,
    List<SavedCard> savedCards, {
    required bool canAcceptInvitations,
  }) {
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

    final ongoingGroups = _groupsForStatus(EventGroupStatus.ongoing);
    final upcomingGroups = _groupsForStatus(EventGroupStatus.upcoming);
    final endedGroups = _groupsForStatus(EventGroupStatus.ended);
    final hasGroupSections = ongoingGroups.isNotEmpty ||
        upcomingGroups.isNotEmpty ||
        endedGroups.isNotEmpty;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, _contentBottomInset),
      children: [
        if (_invitations.isNotEmpty) ...[
          _buildInvitationsSection(
            context,
            canAcceptInvitations: canAcceptInvitations,
          ),
          if (hasGroupSections) const SizedBox(height: 20),
        ],
        if (ongoingGroups.isNotEmpty)
          EventGroupsSection(
            title: context.l10n.eventOngoingSection,
            groups: ongoingGroups,
            linkedCardCountFor: (group) =>
                _savedCardCountForGroup(group.id, savedCards),
            onGroupTap: _openDetail,
          ),
        if (upcomingGroups.isNotEmpty) ...[
          if (ongoingGroups.isNotEmpty) const SizedBox(height: 20),
          EventGroupsSection(
            title: context.l10n.eventUpcomingSection,
            groups: upcomingGroups,
            linkedCardCountFor: (group) =>
                _savedCardCountForGroup(group.id, savedCards),
            onGroupTap: _openDetail,
          ),
        ],
        if (endedGroups.isNotEmpty) ...[
          if (ongoingGroups.isNotEmpty || upcomingGroups.isNotEmpty)
            const SizedBox(height: 20),
          EventGroupsSection(
            title: context.l10n.eventEndedSection,
            groups: endedGroups,
            linkedCardCountFor: (group) =>
                _savedCardCountForGroup(group.id, savedCards),
            onGroupTap: _openDetail,
          ),
        ],
      ],
    );
  }

  List<EventGroup> _groupsForStatus(EventGroupStatus status) {
    final groups =
        _groups.where((group) => group.status == status).toList(growable: false);
    return switch (status) {
      EventGroupStatus.ongoing || EventGroupStatus.upcoming =>
        List<EventGroup>.of(groups)
          ..sort((a, b) => a.startAt.compareTo(b.startAt)),
      EventGroupStatus.ended => List<EventGroup>.of(groups)
        ..sort(
          (a, b) => (b.endAt ?? b.startAt).compareTo(a.endAt ?? a.startAt),
        ),
    };
  }

  Widget _buildInvitationsSection(
    BuildContext context, {
    required bool canAcceptInvitations,
  }) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final title = context.l10n.eventInvitationsSection.toUpperCase();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Text(
            title,
            style: textTheme.labelLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
          ),
        ),
        for (var index = 0; index < _invitations.length; index++) ...[
          if (index > 0) const SizedBox(height: EventGroupsSection.cardSpacing),
          EventGroupInvitationCard(
            invitation: _invitations[index],
            isResponding: _respondingInvitationId == _invitations[index].id,
            canAccept: canAcceptInvitations,
            onAccept: () => _respondToInvitation(
              invitation: _invitations[index],
              accept: true,
            ),
            onReject: () => _respondToInvitation(
              invitation: _invitations[index],
              accept: false,
            ),
          ),
        ],
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
              getEventGroupOutboundInvitations:
                  widget.getEventGroupOutboundInvitations,
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
