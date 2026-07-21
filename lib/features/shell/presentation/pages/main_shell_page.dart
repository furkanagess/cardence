import 'package:flutter/material.dart';
import '../../../../core/l10n/app_l10n.dart';
import '../../../../core/l10n/l10n_extensions.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/atoms/cardence_app_bar.dart';
import '../../../../core/widgets/organisms/cardence_scaffold.dart';
import '../../../event_groups/domain/usecases/get_event_groups.dart';
import '../../../event_groups/domain/usecases/get_event_group_invitations.dart';
import '../../../event_groups/domain/usecases/accept_event_group_invitation.dart';
import '../../../event_groups/domain/usecases/reject_event_group_invitation.dart';
import '../../../event_groups/domain/usecases/create_event_group.dart';
import '../../../event_groups/domain/usecases/delete_event_group.dart';
import '../../../event_groups/domain/usecases/invite_event_group_cards_by_card_id.dart';
import '../../../event_groups/domain/usecases/get_event_group_outbound_invitations.dart';
import '../../../event_groups/domain/usecases/link_event_group_cards.dart';
import '../../../event_groups/domain/usecases/update_event_group.dart';
import '../../../saved_cards/domain/usecases/add_saved_card.dart';
import '../../../saved_cards/domain/usecases/delete_saved_card.dart';
import '../../../saved_cards/domain/usecases/get_saved_cards.dart';
import '../../../saved_cards/domain/usecases/get_saved_cards_wallet_quota.dart';
import '../../../saved_cards/domain/usecases/get_wallet_card_invitations.dart';
import '../../../saved_cards/domain/usecases/accept_wallet_card_invitation.dart';
import '../../../saved_cards/domain/usecases/reject_wallet_card_invitation.dart';
import '../../../saved_cards/domain/usecases/link_saved_cards_to_event_group.dart';
import '../../../saved_cards/domain/usecases/save_saved_card.dart';
import '../../../saved_cards/domain/usecases/track_saved_card_contact_click.dart';
import '../../../saved_cards/domain/usecases/upgrade_wallet_plan.dart';
import '../../../subscriptions/domain/usecases/restore_wallet_purchases.dart';
import '../../../event_groups/presentation/pages/event_groups_page.dart';
import '../../../onboarding/domain/entities/onboarding_card_draft.dart';
import '../../../network_graph/domain/usecases/get_network_graph.dart';
import '../../../network_graph/domain/usecases/get_network_graph_path.dart';
import '../../../plans/domain/usecases/get_plan_entitlements.dart';
import '../../../plans/presentation/cubit/plan_cubit.dart';
import '../../../profile/domain/usecases/get_profile_stats.dart';
import '../../../profile/presentation/pages/profile_page.dart';
import '../../../onboarding/domain/usecases/get_onboarding_draft_card.dart';
import '../../../onboarding/domain/usecases/get_onboarding_draft_cards.dart';
import '../../../business_cards/domain/usecases/persist_onboarding_card.dart';
import '../../../saved_cards/presentation/cubit/saved_cards_cubit.dart';
import '../../../saved_cards/presentation/cubit/saved_cards_state.dart';
import '../../../saved_cards/presentation/widgets/saved_cards_page_header.dart';
import '../../../saved_cards/presentation/pages/saved_cards_page.dart';
import '../../../saved_cards/presentation/pages/wallet_card_invitations_page.dart';
import '../../../saved_cards/presentation/wallet_paywall_flow.dart';
import '../../../auth/domain/usecases/get_current_user.dart';
import '../../../auth/domain/usecases/upload_profile_photo.dart';
import '../../../settings/domain/entities/locale_preference.dart';
import '../../../settings/domain/entities/theme_preference.dart';
import '../../../settings/presentation/pages/settings_page.dart';
import '../../../settings/domain/usecases/request_app_review.dart';
import '../../../support/domain/usecases/submit_support_request.dart';
import '../../../support/presentation/pages/support_page.dart';

/// Ana kabuk: 2 ekran bottom nav ile (ikon only); Ayarlar AppBar'dan.
class MainShellPage extends StatefulWidget {
  const MainShellPage({
    super.key,
    this.showPostOnboardingPaywall = false,
    required this.getOnboardingDraftCard,
    required this.getOnboardingDraftCards,
    required this.persistOnboardingCard,
    required this.getEventGroups,
    required this.getEventGroupInvitations,
    required this.acceptEventGroupInvitation,
    required this.rejectEventGroupInvitation,
    required this.createEventGroup,
    required this.updateEventGroup,
    required this.inviteEventGroupCardsByCardId,
    required this.getEventGroupOutboundInvitations,
    required this.deleteEventGroup,
    required this.linkEventGroupCards,
    required this.linkSavedCardsToEventGroup,
    required this.getSavedCards,
    required this.saveSavedCard,
    required this.getSavedCardsWalletQuota,
    required this.getWalletCardInvitations,
    required this.acceptWalletCardInvitation,
    required this.rejectWalletCardInvitation,
    required this.addSavedCard,
    required this.deleteSavedCard,
    required this.trackSavedCardContactClick,
    required this.upgradeWalletPlan,
    required this.restoreWalletPurchases,
    required this.getCurrentUser,
    required this.getPlanEntitlements,
    required this.getNetworkGraph,
    required this.getNetworkGraphPath,
    required this.themePreference,
    required this.onThemeChanged,
    required this.localePreference,
    required this.onLocaleChanged,
    required this.onLogout,
    required this.onDeleteAccount,
    required this.uploadProfilePhoto,
    required this.submitSupportRequest,
    required this.requestAppReview,
    required this.getProfileStats,
  });

  final bool showPostOnboardingPaywall;
  final GetOnboardingDraftCard getOnboardingDraftCard;
  final GetOnboardingDraftCards getOnboardingDraftCards;
  final PersistOnboardingCard persistOnboardingCard;
  final GetEventGroups getEventGroups;
  final GetEventGroupInvitations getEventGroupInvitations;
  final AcceptEventGroupInvitation acceptEventGroupInvitation;
  final RejectEventGroupInvitation rejectEventGroupInvitation;
  final CreateEventGroup createEventGroup;
  final UpdateEventGroup updateEventGroup;
  final InviteEventGroupCardsByCardId inviteEventGroupCardsByCardId;
  final GetEventGroupOutboundInvitations getEventGroupOutboundInvitations;
  final DeleteEventGroup deleteEventGroup;
  final LinkEventGroupCards linkEventGroupCards;
  final LinkSavedCardsToEventGroup linkSavedCardsToEventGroup;
  final GetSavedCards getSavedCards;
  final SaveSavedCard saveSavedCard;
  final GetSavedCardsWalletQuota getSavedCardsWalletQuota;
  final GetWalletCardInvitations getWalletCardInvitations;
  final AcceptWalletCardInvitation acceptWalletCardInvitation;
  final RejectWalletCardInvitation rejectWalletCardInvitation;
  final AddSavedCard addSavedCard;
  final DeleteSavedCard deleteSavedCard;
  final TrackSavedCardContactClick trackSavedCardContactClick;
  final UpgradeWalletPlan upgradeWalletPlan;
  final RestoreWalletPurchases restoreWalletPurchases;
  final GetCurrentUser getCurrentUser;
  final GetPlanEntitlements getPlanEntitlements;
  final GetNetworkGraph getNetworkGraph;
  final GetNetworkGraphPath getNetworkGraphPath;
  final ThemePreference themePreference;
  final ValueChanged<ThemePreference> onThemeChanged;
  final LocalePreference localePreference;
  final ValueChanged<LocalePreference> onLocaleChanged;
  final Future<void> Function() onLogout;
  final Future<void> Function() onDeleteAccount;
  final UploadProfilePhoto uploadProfilePhoto;
  final SubmitSupportRequest submitSupportRequest;
  final RequestAppReview requestAppReview;
  final GetProfileStats getProfileStats;

  @override
  State<MainShellPage> createState() => _MainShellPageState();
}

class _MainShellPageState extends State<MainShellPage> {
  int _currentIndex = 0;
  OnboardingCardDraft? _myCardDraft;
  final int _savedCardsFilterTrigger = 0;
  final int _savedCardsAddCardTrigger = 0;
  bool _openingSettings = false;

  @override
  void initState() {
    super.initState();
    _loadMyCardDraft();
  }

  Future<void> _loadMyCardDraft() async {
    final draft = await widget.getOnboardingDraftCard();
    if (!mounted) return;
    setState(() => _myCardDraft = draft);
  }

  String get _appBarTitle {
    switch (_currentIndex) {
      case 0:
        return context.l10n.kaydedilenKartlar;
      case 1:
        return context.l10n.etkinlikGruplar;
      case 2:
        return context.l10n.kartlarm;
      default:
        return AppConstants.appName;
    }
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return CardenceAppBar(
      variant: CardenceAppBarVariant.primary,
      titleWidget: CardenceAppBar.shellTabTitle(context, _appBarTitle),
      actions: [
        if (_currentIndex == 0)
          BlocBuilder<SavedCardsCubit, SavedCardsState>(
            buildWhen: (previous, current) => previous.quota != current.quota,
            builder: (context, state) {
              return SavedCardsWalletQuotaBadge(
                quota: state.quota,
                onUpgradeTap: () =>
                    context.read<SavedCardsCubit>().requestUpgradeSheet(),
              );
            },
          ),
        if (_currentIndex == 0)
          BlocBuilder<SavedCardsCubit, SavedCardsState>(
            buildWhen: (previous, current) =>
                previous.invitations.length != current.invitations.length,
            builder: (context, state) {
              final count = state.invitations.length;
              return IconButton(
                tooltip: context.l10n.walletCardInvitationsAppBarTooltip,
                onPressed: () => _openWalletCardInvitations(context),
                icon: Badge(
                  isLabelVisible: count > 0,
                  label: Text(count > 99 ? '99+' : '$count'),
                  child: const Icon(
                    Icons.mail_outline_rounded,
                    size: 24,
                  ),
                ),
              );
            },
          ),
        if (_currentIndex != 0)
          CardenceAppBar.iconAction(
            icon: Icons.settings_outlined,
            tooltip: context.l10n.ayarlar,
            onPressed: _openingSettings ? null : () => _openSettings(context),
          ),
      ],
    );
  }

  Future<void> _openWalletCardInvitations(BuildContext context) async {
    final cubit = context.read<SavedCardsCubit>();
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => BlocProvider.value(
          value: cubit,
          child: const WalletCardInvitationsPage(),
        ),
      ),
    );
    if (!context.mounted) return;
    await cubit.refreshAll();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => SavedCardsCubit(
            getSavedCards: widget.getSavedCards,
            saveSavedCard: widget.saveSavedCard,
            getEventGroups: widget.getEventGroups,
            getSavedCardsWalletQuota: widget.getSavedCardsWalletQuota,
            upgradeWalletPlan: widget.upgradeWalletPlan,
            getWalletCardInvitations: widget.getWalletCardInvitations,
            acceptWalletCardInvitation: widget.acceptWalletCardInvitation,
            rejectWalletCardInvitation: widget.rejectWalletCardInvitation,
          )..load(),
        ),
        BlocProvider(
          create: (_) => PlanCubit(
            getPlanEntitlements: widget.getPlanEntitlements,
          )..load(),
        ),
      ],
      child: _PostOnboardingPaywallGate(
        enabled: widget.showPostOnboardingPaywall,
        child: CardenceScaffold(
          appBar: _buildAppBar(context),
          body: IndexedStack(
            index: _currentIndex,
            children: [
              HeroMode(
                enabled: _currentIndex == 0,
                child: SavedCardsPage(
                getEventGroups: widget.getEventGroups,
                getSavedCards: widget.getSavedCards,
                updateEventGroup: widget.updateEventGroup,
                inviteEventGroupCardsByCardId:
                    widget.inviteEventGroupCardsByCardId,
                getEventGroupOutboundInvitations:
                    widget.getEventGroupOutboundInvitations,
                deleteEventGroup: widget.deleteEventGroup,
                linkSavedCardsToEventGroup: widget.linkSavedCardsToEventGroup,
                saveSavedCard: widget.saveSavedCard,
                deleteSavedCard: widget.deleteSavedCard,
                addSavedCard: widget.addSavedCard,
                upgradeWalletPlan: widget.upgradeWalletPlan,
                trackSavedCardContactClick: widget.trackSavedCardContactClick,
                restoreWalletPurchases: widget.restoreWalletPurchases,
                filterTrigger: _savedCardsFilterTrigger,
                addCardTrigger: _savedCardsAddCardTrigger,
              ),
              ),
              HeroMode(
                enabled: _currentIndex == 1,
                child: EventGroupsPage(
                getEventGroups: widget.getEventGroups,
                getEventGroupInvitations: widget.getEventGroupInvitations,
                acceptEventGroupInvitation: widget.acceptEventGroupInvitation,
                rejectEventGroupInvitation: widget.rejectEventGroupInvitation,
                createEventGroup: widget.createEventGroup,
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
                restoreWalletPurchases: widget.restoreWalletPurchases,
                getNetworkGraph: widget.getNetworkGraph,
                getNetworkGraphPath: widget.getNetworkGraphPath,
              ),
              ),
              HeroMode(
                enabled: _currentIndex == 2,
                child: ProfilePage(
                draft: _myCardDraft,
                getOnboardingDraftCards: widget.getOnboardingDraftCards,
                persistOnboardingCard: widget.persistOnboardingCard,
                getProfileStats: widget.getProfileStats,
                getNetworkGraph: widget.getNetworkGraph,
                getNetworkGraphPath: widget.getNetworkGraphPath,
                getEventGroups: widget.getEventGroups,
                uploadProfilePhoto: widget.uploadProfilePhoto,
                upgradeWalletPlan: widget.upgradeWalletPlan,
                onDraftUpdated: (updated) =>
                    setState(() => _myCardDraft = updated),
              ),
              ),
            ],
          ),
          extendBody: true,
          bottomNavigationBar: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
              child: _LiquidGlassBottomNavBar(
                currentIndex: _currentIndex,
                itemCount: 3,
                onTap: (index) => setState(() => _currentIndex = index),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openSettings(BuildContext context) async {
    if (_openingSettings) return;
    setState(() => _openingSettings = true);

    try {
      final user = await widget.getCurrentUser();
      if (!context.mounted) return;

      final draft = _myCardDraft;
      final displayName = user.displayName?.trim().isNotEmpty == true
          ? user.displayName!
          : (draft?.displayName?.trim().isNotEmpty == true
              ? draft!.displayName!
              : (draft?.cardName?.trim().isNotEmpty == true
                  ? draft!.cardName!
                  : AppL10n.userLabel(context.l10n)));

      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (context) => SettingsPage(
            currentTheme: widget.themePreference,
            onThemeChanged: widget.onThemeChanged,
            currentLocale: widget.localePreference,
            onLocaleChanged: widget.onLocaleChanged,
            onLogout: widget.onLogout,
            onDeleteAccount: widget.onDeleteAccount,
            userDisplayName: displayName,
            userEmail: user.email ?? draft?.email,
            userPhotoUrl: draft?.photoUrl ?? user.photoUrl,
            uploadProfilePhoto: widget.uploadProfilePhoto,
            onPhotoUpdated: (photoUrl) {
              if (photoUrl != null && draft != null) {
                setState(
                  () => _myCardDraft = draft.copyWith(photoUrl: photoUrl),
                );
              }
              _loadMyCardDraft();
            },
            onOpenSupport: () => _openSupport(
              context,
              user.email ?? draft?.email,
            ),
            requestAppReview: widget.requestAppReview,
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _openingSettings = false);
    }
  }

  void _openSupport(BuildContext context, String? initialEmail) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => SupportPage(
          submitSupportRequest: widget.submitSupportRequest,
          initialEmail: initialEmail,
        ),
      ),
    );
  }
}

/// Bottom nav: opak yüzey, sliding pill indicator.
class _LiquidGlassBottomNavBar extends StatefulWidget {
  const _LiquidGlassBottomNavBar({
    required this.currentIndex,
    required this.itemCount,
    required this.onTap,
  });

  final int currentIndex;
  final int itemCount;
  final ValueChanged<int> onTap;

  @override
  State<_LiquidGlassBottomNavBar> createState() =>
      _LiquidGlassBottomNavBarState();
}

class _LiquidGlassBottomNavBarState extends State<_LiquidGlassBottomNavBar> {
  int _previousIndex = 0;

  @override
  void initState() {
    super.initState();
    _previousIndex = widget.currentIndex;
  }

  @override
  void didUpdateWidget(_LiquidGlassBottomNavBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      Future.delayed(const Duration(milliseconds: 280), () {
        if (mounted) setState(() => _previousIndex = widget.currentIndex);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final navSurface = colorScheme.surface;
    final borderColor = colorScheme.outline;
    final pillColor = colorScheme.inverseSurface;
    final selectedIconColor = colorScheme.onInverseSurface;

    return LayoutBuilder(
      builder: (context, constraints) {
        final navWidth = constraints.maxWidth;
        final itemWidth = navWidth / widget.itemCount;
        const indicatorPadding = 6.0;
        final indicatorWidth = itemWidth - (indicatorPadding * 2);

        return SizedBox(
          height: 56,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(28),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(28),
                      color: navSurface,
                      border: Border.all(
                        color: borderColor,
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: colorScheme.shadow.withValues(alpha: 0.12),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                          spreadRadius: -2,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              TweenAnimationBuilder<double>(
                tween: Tween(
                  begin: _previousIndex.toDouble(),
                  end: widget.currentIndex.toDouble(),
                ),
                duration: const Duration(milliseconds: 280),
                curve: Curves.easeOutCubic,
                builder: (context, value, child) {
                  final left = (value * itemWidth) + indicatorPadding;
                  return Positioned(
                    left: left,
                    top: 4,
                    bottom: 4,
                    width: indicatorWidth,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        color: pillColor,
                      ),
                    ),
                  );
                },
              ),
              Positioned.fill(
                child: Row(
                  children: [
                    Expanded(
                      child: _NavItem(
                        icon: Icons.people_outline_rounded,
                        selected: widget.currentIndex == 0,
                        selectedColor: selectedIconColor,
                        onTap: () => widget.onTap(0),
                        theme: theme,
                      ),
                    ),
                    Expanded(
                      child: _NavItem(
                        icon: Icons.event_note_rounded,
                        selected: widget.currentIndex == 1,
                        selectedColor: selectedIconColor,
                        onTap: () => widget.onTap(1),
                        theme: theme,
                      ),
                    ),
                    Expanded(
                      child: _NavItem(
                        icon: Icons.person_rounded,
                        selected: widget.currentIndex == 2,
                        selectedColor: selectedIconColor,
                        onTap: () => widget.onTap(2),
                        theme: theme,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.selected,
    required this.selectedColor,
    required this.onTap,
    required this.theme,
  });

  final IconData icon;
  final bool selected;
  final Color selectedColor;
  final VoidCallback onTap;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final unselectedColor = theme.colorScheme.onSurface.withValues(alpha: 0.75);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(28),
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        hoverColor: Colors.transparent,
        focusColor: Colors.transparent,
        overlayColor: const WidgetStatePropertyAll<Color>(Colors.transparent),
        child: Container(
          height: 48,
          alignment: Alignment.center,
          child: Icon(
            icon,
            size: selected ? 22 : 18,
            color: selected ? selectedColor : unselectedColor,
          ),
        ),
      ),
    );
  }
}

/// Onboarding sonrası ilk ana ekran girişinde RevenueCat paywall gösterir.
class _PostOnboardingPaywallGate extends StatefulWidget {
  const _PostOnboardingPaywallGate({
    required this.enabled,
    required this.child,
  });

  final bool enabled;
  final Widget child;

  @override
  State<_PostOnboardingPaywallGate> createState() =>
      _PostOnboardingPaywallGateState();
}

class _PostOnboardingPaywallGateState
    extends State<_PostOnboardingPaywallGate> {
  bool _handled = false;

  @override
  void initState() {
    super.initState();
    if (widget.enabled) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _presentPaywall());
    }
  }

  Future<void> _presentPaywall() async {
    if (!mounted || _handled || !widget.enabled) return;
    _handled = true;

    final cubit = context.read<SavedCardsCubit>();
    if (cubit.state.quota.isPremium) return;

    try {
      await WalletPaywallFlow.show(
        context,
        cubit: cubit,
        onlyIfNeeded: true,
      );
    } catch (_) {
      // Paywall açılamazsa uygulama akışı devam eder.
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
