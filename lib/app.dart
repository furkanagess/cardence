import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:app_links/app_links.dart';

import 'l10n/app_localizations.dart';

import 'core/auth/auth_token_coordinator.dart';
import 'core/auth/session_expired_handler.dart';
import 'core/constants/app_constants.dart';
import 'core/init/app_init.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/splash_theme.dart';
import 'core/widgets/molecules/chuck_fab_overlay.dart';
import 'core/widgets/organisms/cardence_logo_merge_animation.dart';
import 'core/widgets/organisms/cardence_scaffold.dart';
import 'features/auth/domain/usecases/get_auth_session.dart';
import 'features/auth/domain/usecases/delete_account.dart';
import 'features/auth/domain/usecases/forgot_password.dart';
import 'features/auth/domain/usecases/get_current_user.dart';
import 'features/auth/domain/usecases/get_last_login_credentials.dart';
import 'features/auth/domain/usecases/login_with_apple.dart';
import 'features/auth/domain/usecases/login_with_email.dart';
import 'features/auth/domain/usecases/login_with_google.dart';
import 'features/auth/domain/usecases/login_with_linkedin.dart';
import 'features/auth/domain/usecases/login_with_phone.dart';
import 'features/auth/domain/usecases/logout.dart';
import 'features/auth/domain/usecases/register_user.dart';
import 'features/auth/domain/usecases/reset_password.dart';
import 'features/auth/domain/usecases/restore_auth_session.dart';
import 'features/auth/domain/usecases/upload_profile_photo.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/pages/reset_password_from_link_page.dart';
import 'features/auth/presentation/helpers/password_reset_deep_link.dart';
import 'features/event_groups/domain/usecases/get_event_groups.dart';
import 'features/event_groups/domain/usecases/get_event_group_invitations.dart';
import 'features/event_groups/domain/usecases/get_event_group_outbound_invitations.dart';
import 'features/event_groups/domain/usecases/accept_event_group_invitation.dart';
import 'features/event_groups/domain/usecases/reject_event_group_invitation.dart';
import 'features/event_groups/domain/usecases/create_event_group.dart';
import 'features/event_groups/domain/usecases/delete_event_group.dart';
import 'features/event_groups/domain/usecases/invite_event_group_cards_by_card_id.dart';
import 'features/event_groups/domain/usecases/link_event_group_cards.dart';
import 'features/event_groups/domain/usecases/update_event_group.dart';
import 'features/onboarding/domain/usecases/get_onboarding_completed.dart';
import 'features/onboarding/domain/usecases/get_onboarding_draft_card.dart';
import 'features/onboarding/domain/usecases/get_onboarding_draft_cards.dart';
import 'features/onboarding/domain/usecases/resolve_onboarding_initial_draft.dart';
import 'features/business_cards/domain/usecases/persist_onboarding_card.dart';
import 'features/business_cards/domain/usecases/save_business_card.dart';
import 'features/onboarding/domain/usecases/sync_onboarding_from_server.dart';
import 'features/onboarding/presentation/pages/onboarding_page.dart';
import 'features/network_graph/domain/usecases/get_network_graph.dart';
import 'features/network_graph/domain/usecases/get_network_graph_path.dart';
import 'features/plans/domain/usecases/get_plan_entitlements.dart';
import 'features/saved_cards/domain/usecases/add_saved_card.dart';
import 'features/saved_cards/domain/usecases/delete_saved_card.dart';
import 'features/saved_cards/domain/usecases/get_saved_cards.dart';
import 'features/saved_cards/domain/usecases/get_saved_cards_wallet_quota.dart';
import 'features/saved_cards/domain/usecases/get_wallet_card_invitations.dart';
import 'features/saved_cards/domain/usecases/accept_wallet_card_invitation.dart';
import 'features/saved_cards/domain/usecases/reject_wallet_card_invitation.dart';
import 'features/saved_cards/domain/usecases/link_saved_cards_to_event_group.dart';
import 'features/saved_cards/domain/usecases/save_saved_card.dart';
import 'features/saved_cards/domain/usecases/track_saved_card_contact_click.dart';
import 'features/saved_cards/domain/usecases/upgrade_wallet_plan.dart';
import 'features/saved_cards/presentation/cubit/saved_cards_cubit.dart';
import 'features/saved_cards/presentation/pages/wallet_card_invitations_page.dart';
import 'features/subscriptions/domain/usecases/identify_subscription_user.dart';
import 'features/subscriptions/domain/usecases/set_subscription_preferred_locale.dart';
import 'features/subscriptions/domain/usecases/restore_wallet_purchases.dart';
import 'features/subscriptions/presentation/helpers/premium_purchase_success_handler.dart';
import 'features/subscriptions/presentation/widgets/premium_purchase_scope.dart';
import 'core/l10n/locale_preference_material.dart';
import 'core/notifications/push_notification_coordinator.dart';
import 'features/settings/domain/entities/locale_preference.dart';
import 'features/settings/domain/entities/theme_preference.dart';
import 'features/settings/domain/usecases/get_accent_color_id.dart';
import 'features/settings/domain/usecases/get_locale_preference.dart';
import 'features/settings/domain/usecases/get_theme_preference.dart';
import 'features/settings/domain/usecases/request_app_review.dart';
import 'features/settings/domain/usecases/set_accent_color_id.dart';
import 'features/settings/domain/usecases/set_locale_preference.dart';
import 'features/settings/domain/usecases/set_theme_preference.dart';
import 'core/theme/app_accent_palette.dart';
import 'features/profile/domain/usecases/get_profile_stats.dart';
import 'features/support/domain/usecases/submit_support_request.dart';
import 'features/shell/presentation/pages/main_shell_page.dart';

enum _AppDestination { loading, login, onboarding, main }

/// Uygulama kökü: login → onboarding → ana kabuk.
class App extends StatefulWidget {
  const App({
    super.key,
    required this.rootNavigatorKey,
    required this.restoreAuthSession,
    required this.getAuthSession,
    required this.identifySubscriptionUser,
    required this.setSubscriptionPreferredLocale,
    required this.loginWithEmail,
    required this.loginWithPhone,
    required this.loginWithLinkedIn,
    required this.loginWithGoogle,
    required this.loginWithApple,
    required this.registerUser,
    required this.getLastLoginCredentials,
    required this.forgotPassword,
    required this.resetPassword,
    required this.getCurrentUser,
    required this.logout,
    required this.deleteAccount,
    required this.uploadProfilePhoto,
    required this.getOnboardingCompleted,
    required this.completeOnboarding,
    required this.syncOnboardingFromServer,
    required this.persistOnboardingCard,
    required this.saveBusinessCard,
    required this.getOnboardingDraftCard,
    required this.getOnboardingDraftCards,
    required this.resolveOnboardingInitialDraft,
    required this.getThemePreference,
    required this.setThemePreference,
    required this.getAccentColorId,
    required this.setAccentColorId,
    required this.initialThemePreference,
    required this.initialAccentColorId,
    required this.getLocalePreference,
    required this.setLocalePreference,
    required this.initialLocalePreference,
    required this.submitSupportRequest,
    required this.requestAppReview,
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
    required this.premiumPurchaseSuccessHandler,
    required this.getProfileStats,
    required this.getPlanEntitlements,
    required this.getNetworkGraph,
    required this.getNetworkGraphPath,
  });

  factory App.withInitResult({
    required GlobalKey<NavigatorState> rootNavigatorKey,
    required AppInitResult init,
  }) {
    return App(
      rootNavigatorKey: rootNavigatorKey,
      restoreAuthSession: init.restoreAuthSession,
      getAuthSession: init.getAuthSession,
      identifySubscriptionUser: init.identifySubscriptionUser,
      setSubscriptionPreferredLocale: init.setSubscriptionPreferredLocale,
      loginWithEmail: init.loginWithEmail,
      loginWithPhone: init.loginWithPhone,
      loginWithLinkedIn: init.loginWithLinkedIn,
      loginWithGoogle: init.loginWithGoogle,
      loginWithApple: init.loginWithApple,
      registerUser: init.registerUser,
      getLastLoginCredentials: init.getLastLoginCredentials,
      forgotPassword: init.forgotPassword,
      resetPassword: init.resetPassword,
      getCurrentUser: init.getCurrentUser,
      logout: init.logout,
      deleteAccount: init.deleteAccount,
      uploadProfilePhoto: init.uploadProfilePhoto,
      getOnboardingCompleted: init.getOnboardingCompleted,
      completeOnboarding: init.completeOnboarding,
      syncOnboardingFromServer: init.syncOnboardingFromServer,
      persistOnboardingCard: init.persistOnboardingCard,
      saveBusinessCard: init.saveBusinessCard,
      getOnboardingDraftCard: init.getOnboardingDraftCard,
      getOnboardingDraftCards: init.getOnboardingDraftCards,
      resolveOnboardingInitialDraft: init.resolveOnboardingInitialDraft,
      getThemePreference: init.getThemePreference,
      setThemePreference: init.setThemePreference,
      getAccentColorId: init.getAccentColorId,
      setAccentColorId: init.setAccentColorId,
      initialThemePreference: init.initialThemePreference,
      initialAccentColorId: init.initialAccentColorId,
      getLocalePreference: init.getLocalePreference,
      setLocalePreference: init.setLocalePreference,
      initialLocalePreference: init.initialLocalePreference,
      submitSupportRequest: init.submitSupportRequest,
      requestAppReview: init.requestAppReview,
      getEventGroups: init.getEventGroups,
      getEventGroupInvitations: init.getEventGroupInvitations,
      acceptEventGroupInvitation: init.acceptEventGroupInvitation,
      rejectEventGroupInvitation: init.rejectEventGroupInvitation,
      createEventGroup: init.createEventGroup,
      updateEventGroup: init.updateEventGroup,
      inviteEventGroupCardsByCardId: init.inviteEventGroupCardsByCardId,
      getEventGroupOutboundInvitations: init.getEventGroupOutboundInvitations,
      deleteEventGroup: init.deleteEventGroup,
      linkEventGroupCards: init.linkEventGroupCards,
      linkSavedCardsToEventGroup: init.linkSavedCardsToEventGroup,
      getSavedCards: init.getSavedCards,
      saveSavedCard: init.saveSavedCard,
      getSavedCardsWalletQuota: init.getSavedCardsWalletQuota,
      getWalletCardInvitations: init.getWalletCardInvitations,
      acceptWalletCardInvitation: init.acceptWalletCardInvitation,
      rejectWalletCardInvitation: init.rejectWalletCardInvitation,
      addSavedCard: init.addSavedCard,
      deleteSavedCard: init.deleteSavedCard,
      trackSavedCardContactClick: init.trackSavedCardContactClick,
      upgradeWalletPlan: init.upgradeWalletPlan,
      restoreWalletPurchases: init.restoreWalletPurchases,
      premiumPurchaseSuccessHandler: init.premiumPurchaseSuccessHandler,
      getProfileStats: init.getProfileStats,
      getPlanEntitlements: init.getPlanEntitlements,
      getNetworkGraph: init.getNetworkGraph,
      getNetworkGraphPath: init.getNetworkGraphPath,
    );
  }

  final GlobalKey<NavigatorState> rootNavigatorKey;
  final RestoreAuthSession restoreAuthSession;
  final GetAuthSession getAuthSession;
  final IdentifySubscriptionUser identifySubscriptionUser;
  final SetSubscriptionPreferredLocale setSubscriptionPreferredLocale;
  final LoginWithEmail loginWithEmail;
  final LoginWithPhone loginWithPhone;
  final LoginWithLinkedIn loginWithLinkedIn;
  final LoginWithGoogle loginWithGoogle;
  final LoginWithApple loginWithApple;
  final RegisterUser registerUser;
  final GetLastLoginCredentials getLastLoginCredentials;
  final ForgotPassword forgotPassword;
  final ResetPassword resetPassword;
  final GetCurrentUser getCurrentUser;
  final Logout logout;
  final DeleteAccount deleteAccount;
  final UploadProfilePhoto uploadProfilePhoto;
  final GetOnboardingCompleted getOnboardingCompleted;
  final Future<void> Function() completeOnboarding;
  final SyncOnboardingFromServer syncOnboardingFromServer;
  final PersistOnboardingCard persistOnboardingCard;
  final SaveBusinessCard saveBusinessCard;
  final GetOnboardingDraftCard getOnboardingDraftCard;
  final GetOnboardingDraftCards getOnboardingDraftCards;
  final ResolveOnboardingInitialDraft resolveOnboardingInitialDraft;
  final GetThemePreference getThemePreference;
  final SetThemePreference setThemePreference;
  final GetAccentColorId getAccentColorId;
  final SetAccentColorId setAccentColorId;
  final ThemePreference initialThemePreference;
  final String initialAccentColorId;
  final GetLocalePreference getLocalePreference;
  final SetLocalePreference setLocalePreference;
  final LocalePreference initialLocalePreference;
  final SubmitSupportRequest submitSupportRequest;
  final RequestAppReview requestAppReview;
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
  final PremiumPurchaseSuccessHandler premiumPurchaseSuccessHandler;
  final GetProfileStats getProfileStats;
  final GetPlanEntitlements getPlanEntitlements;
  final GetNetworkGraph getNetworkGraph;
  final GetNetworkGraphPath getNetworkGraphPath;

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  _AppDestination _destination = _AppDestination.loading;
  late ThemePreference _themePreference;
  late LocalePreference _localePreference;
  late String _accentColorId;
  bool _showPostOnboardingPaywall = false;
  final AppLinks _appLinks = AppLinks();
  StreamSubscription<Uri>? _passwordResetLinkSub;

  @override
  void initState() {
    super.initState();
    _themePreference = widget.initialThemePreference;
    _localePreference = widget.initialLocalePreference;
    _accentColorId = widget.initialAccentColorId;
    AppAccentPalette.init(_accentColorId);
    SessionExpiredHandler.instance.configure(
      navigatorKey: widget.rootNavigatorKey,
      onForceLogout: _onLogout,
      hasStoredSession: () =>
          AuthTokenCoordinator.instance?.hasStoredSession() ??
          Future.value(false),
    );
    PushNotificationCoordinator.instance?.onNotificationTap =
        _handlePushNotificationTap;
    _bootstrap();
    _loadTheme();
    _loadLocale();
    _initPasswordResetLinks();
  }

  @override
  void dispose() {
    _passwordResetLinkSub?.cancel();
    super.dispose();
  }

  Future<void> _initPasswordResetLinks() async {
    try {
      final initial = await _appLinks.getInitialLink();
      if (initial != null) {
        _handlePasswordResetUri(initial);
      }
    } catch (_) {}

    _passwordResetLinkSub = _appLinks.uriLinkStream.listen(
      _handlePasswordResetUri,
      onError: (_) {},
    );
  }

  void _handlePasswordResetUri(Uri uri) {
    final params = parsePasswordResetLink(uri);
    if (params == null || !mounted) {
      return;
    }

    widget.rootNavigatorKey.currentState?.push(
      MaterialPageRoute<void>(
        builder: (_) => ResetPasswordFromLinkPage(
          resetPassword: widget.resetPassword,
          resetToken: params.token,
          email: params.email,
          onResetSuccess: _onLoginSuccess,
        ),
      ),
    );
  }

  Future<void> _bootstrap() async {
    await Future.wait([
      _resolveInitialDestination(),
      Future<void>.delayed(CardenceLogoMergeAnimation.minSplashVisibleDuration),
    ]);
  }

  Future<void> _resolveInitialDestination() async {
    final restored = await widget.restoreAuthSession();
    if (!mounted) return;

    if (!restored.isAuthenticated) {
      setState(() => _destination = _AppDestination.login);
      return;
    }

    var onboardingDone = restored.onboardingCompleted == true;
    if (restored.onboardingCompleted == null) {
      onboardingDone = await widget.getOnboardingCompleted();
    }
    unawaited(
      widget.syncOnboardingFromServer(completed: onboardingDone),
    );
    unawaited(PushNotificationCoordinator.instance?.syncTokenForCurrentSession());

    setState(() {
      _destination =
          onboardingDone ? _AppDestination.main : _AppDestination.onboarding;
    });
  }

  Future<void> _resolvePostLoginDestination() async {
    // Profil /Me login sırasında çekildi (onProfileSynced). Tekrar API çağırma.
    // Yerel okuma takılırsa login ekranında kalmamak için timeout + ana sayfa.
    var completed = true;
    try {
      completed = await widget.getOnboardingCompleted().timeout(
            const Duration(seconds: 2),
            onTimeout: () => true,
          );
    } catch (_) {
      completed = true;
    }
    if (!mounted) return;
    setState(() {
      _destination =
          completed ? _AppDestination.main : _AppDestination.onboarding;
    });
  }

  Future<void> _loadTheme() async {
    final pref = await widget.getThemePreference();
    if (!mounted) return;
    setState(() => _themePreference = pref);
  }

  Future<void> _loadLocale() async {
    final pref = await widget.getLocalePreference();
    if (!mounted) return;
    setState(() => _localePreference = pref);
  }

  void _onLoginSuccess({bool fromRegistration = false}) {
    unawaited(_handleAuthSuccess(fromRegistration: fromRegistration));
  }

  Future<void> _handleAuthSuccess({required bool fromRegistration}) async {
    await _identifySubscriptionUser();
    unawaited(PushNotificationCoordinator.instance?.syncTokenForCurrentSession());
    try {
      if (fromRegistration) {
        await _goToOnboardingAfterRegistration().timeout(
          const Duration(seconds: 3),
        );
        return;
      }
      await _resolvePostLoginDestination().timeout(
        const Duration(seconds: 3),
      );
    } catch (error, stackTrace) {
      debugPrint('[App] Auth success navigation failed: $error');
      debugPrintStack(stackTrace: stackTrace);
      if (!mounted) return;
      // Login başarılıysa asla login ekranında bırakma.
      setState(() {
        _destination = fromRegistration
            ? _AppDestination.onboarding
            : _AppDestination.main;
      });
    }
  }

  Future<void> _goToOnboardingAfterRegistration() async {
    try {
      await widget.syncOnboardingFromServer(completed: false).timeout(
            const Duration(seconds: 2),
          );
    } catch (_) {}
    if (!mounted) return;
    setState(() => _destination = _AppDestination.onboarding);
  }

  Future<void> _identifySubscriptionUser() async {
    final session = await widget.getAuthSession();
    if (session == null || session.userId.isEmpty) return;
    await widget.identifySubscriptionUser(session.userId);
  }

  void _handlePushNotificationTap(Map<String, dynamic> data) {
    if (!mounted) return;

    final navContext = widget.rootNavigatorKey.currentContext ?? context;

    if (isWalletCardInviteNotification(data) ||
        isCardSavedNotification(data)) {
      Navigator.of(navContext).push(
        MaterialPageRoute<void>(
          builder: (_) => BlocProvider(
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
            child: const WalletCardInvitationsPage(),
          ),
        ),
      );
      return;
    }

    final messenger = ScaffoldMessenger.maybeOf(navContext);
    if (messenger == null) return;

    if (isEventGroupInviteNotification(data)) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Yeni bir etkinlik davetiniz var.')),
      );
    }
  }

  void _onOnboardingFinish() {
    setState(() {
      _showPostOnboardingPaywall = true;
      _destination = _AppDestination.main;
    });
  }

  Future<void> _onLogout() async {
    widget.rootNavigatorKey.currentState?.popUntil((route) => route.isFirst);
    if (!mounted) return;
    setState(() => _destination = _AppDestination.login);
    await widget.logout();
  }

  Future<void> _onDeleteAccount() async {
    await widget.deleteAccount();
    if (!mounted) return;
    widget.rootNavigatorKey.currentState?.popUntil((route) => route.isFirst);
    setState(() => _destination = _AppDestination.login);
  }

  void _onThemeChanged(ThemePreference preference) async {
    await widget.setThemePreference(preference);
    if (!mounted) return;
    setState(() => _themePreference = preference);
  }

  void _onLocaleChanged(LocalePreference preference) async {
    await widget.setLocalePreference(preference);
    if (!mounted) return;
    setState(() => _localePreference = preference);
    unawaited(
      widget.setSubscriptionPreferredLocale(
        revenueCatPreferredLocaleForPreference(preference),
      ),
    );
  }

  ThemeMode get _themeMode {
    switch (_themePreference) {
      case ThemePreference.light:
        return ThemeMode.light;
      case ThemePreference.dark:
        return ThemeMode.dark;
      case ThemePreference.system:
        return ThemeMode.system;
    }
  }

  Widget _buildHome() {
    switch (_destination) {
      case _AppDestination.loading:
        return const _SplashContent();
      case _AppDestination.login:
        return LoginPage(
          loginWithEmail: widget.loginWithEmail,
          loginWithPhone: widget.loginWithPhone,
          loginWithLinkedIn: widget.loginWithLinkedIn,
          loginWithGoogle: widget.loginWithGoogle,
          loginWithApple: widget.loginWithApple,
          registerUser: widget.registerUser,
          getLastLoginCredentials: widget.getLastLoginCredentials,
          forgotPassword: widget.forgotPassword,
          resetPassword: widget.resetPassword,
          onLoginSuccess: _onLoginSuccess,
        );
      case _AppDestination.onboarding:
        return OnboardingPageView(
          completeOnboarding: widget.completeOnboarding,
          resolveInitialDraft: widget.resolveOnboardingInitialDraft,
          persistOnboardingCard: widget.persistOnboardingCard,
          uploadProfilePhoto: widget.uploadProfilePhoto,
          upgradeWalletPlan: widget.upgradeWalletPlan,
          onFinish: (_) => _onOnboardingFinish(),
        );
      case _AppDestination.main:
        return MainShellPage(
          showPostOnboardingPaywall: _showPostOnboardingPaywall,
          getOnboardingDraftCard: widget.getOnboardingDraftCard,
          getOnboardingDraftCards: widget.getOnboardingDraftCards,
          persistOnboardingCard: widget.persistOnboardingCard,
          getEventGroups: widget.getEventGroups,
          getEventGroupInvitations: widget.getEventGroupInvitations,
          acceptEventGroupInvitation: widget.acceptEventGroupInvitation,
          rejectEventGroupInvitation: widget.rejectEventGroupInvitation,
          createEventGroup: widget.createEventGroup,
          updateEventGroup: widget.updateEventGroup,
          inviteEventGroupCardsByCardId: widget.inviteEventGroupCardsByCardId,
          getEventGroupOutboundInvitations:
              widget.getEventGroupOutboundInvitations,
          deleteEventGroup: widget.deleteEventGroup,
          linkEventGroupCards: widget.linkEventGroupCards,
          linkSavedCardsToEventGroup: widget.linkSavedCardsToEventGroup,
          getSavedCards: widget.getSavedCards,
          saveSavedCard: widget.saveSavedCard,
          getSavedCardsWalletQuota: widget.getSavedCardsWalletQuota,
          getWalletCardInvitations: widget.getWalletCardInvitations,
          acceptWalletCardInvitation: widget.acceptWalletCardInvitation,
          rejectWalletCardInvitation: widget.rejectWalletCardInvitation,
          addSavedCard: widget.addSavedCard,
          deleteSavedCard: widget.deleteSavedCard,
          trackSavedCardContactClick: widget.trackSavedCardContactClick,
          upgradeWalletPlan: widget.upgradeWalletPlan,
          restoreWalletPurchases: widget.restoreWalletPurchases,
          getCurrentUser: widget.getCurrentUser,
          getPlanEntitlements: widget.getPlanEntitlements,
          getNetworkGraph: widget.getNetworkGraph,
          getNetworkGraphPath: widget.getNetworkGraphPath,
          themePreference: _themePreference,
          onThemeChanged: _onThemeChanged,
          localePreference: _localePreference,
          onLocaleChanged: _onLocaleChanged,
          onLogout: _onLogout,
          onDeleteAccount: _onDeleteAccount,
          uploadProfilePhoto: widget.uploadProfilePhoto,
          submitSupportRequest: widget.submitSupportRequest,
          requestAppReview: widget.requestAppReview,
          getProfileStats: widget.getProfileStats,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      key: ValueKey('app-theme-$_accentColorId'),
      navigatorKey: widget.rootNavigatorKey,
      title: 'Cardence',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _themeMode,
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      locale: materialLocaleFor(_localePreference),
      builder: (context, child) {
        final mediaQueryData = MediaQuery.of(context);
        return MediaQuery(
          data: mediaQueryData.copyWith(
            textScaler: TextScaler.noScaling,
          ),
          child: PremiumPurchaseScope(
            handler: widget.premiumPurchaseSuccessHandler,
            child: ChuckFabOverlay(
              child: child ?? const SizedBox.shrink(),
            ),
          ),
        );
      },
      home: _buildHome(),
    );
  }
}

class _SplashContent extends StatelessWidget {
  const _SplashContent();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final backgroundColor = SplashTheme.background(theme.brightness);

    return CardenceScaffold(
      showWatermark: !isDark,
      backgroundColor: backgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CardenceLogoMergeAnimation(
              size: CardenceLogoMergeAnimation.splashSize,
              repeat: false,
              logoAssetPath: SplashTheme.logoAsset(theme.brightness),
            ),
            const SizedBox(height: 24),
            Text(
              AppConstants.appName,
              style: theme.textTheme.headlineSmall?.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.4,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              AppConstants.appTagline,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: theme.colorScheme.primary.withValues(
                  alpha: isDark ? 0.9 : 0.75,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
