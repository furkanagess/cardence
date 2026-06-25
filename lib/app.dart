import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'l10n/app_localizations.dart';

import 'core/auth/session_expired_handler.dart';
import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/splash_theme.dart';
import 'core/widgets/molecules/chuck_fab_overlay.dart';
import 'core/widgets/organisms/cardence_connect_animation.dart';
import 'core/widgets/organisms/cardence_scaffold.dart';
import 'features/auth/domain/usecases/get_auth_session.dart';
import 'features/auth/domain/usecases/forgot_password.dart';
import 'features/auth/domain/usecases/get_current_user.dart';
import 'features/auth/domain/usecases/get_last_login_credentials.dart';
import 'features/auth/domain/usecases/login_with_email.dart';
import 'features/auth/domain/usecases/login_with_linkedin.dart';
import 'features/auth/domain/usecases/login_with_phone.dart';
import 'features/auth/domain/usecases/logout.dart';
import 'features/auth/domain/usecases/register_user.dart';
import 'features/auth/domain/usecases/reset_password.dart';
import 'features/auth/domain/usecases/restore_auth_session.dart';
import 'features/auth/domain/usecases/upload_profile_photo.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/event_groups/domain/usecases/get_event_groups.dart';
import 'features/event_groups/domain/usecases/create_event_group.dart';
import 'features/event_groups/domain/usecases/delete_event_group.dart';
import 'features/event_groups/domain/usecases/link_event_group_cards.dart';
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
import 'features/saved_cards/domain/usecases/link_saved_cards_to_event_group.dart';
import 'features/saved_cards/domain/usecases/save_saved_card.dart';
import 'features/saved_cards/domain/usecases/track_saved_card_contact_click.dart';
import 'features/saved_cards/domain/usecases/upgrade_wallet_plan.dart';
import 'features/subscriptions/domain/usecases/identify_subscription_user.dart';
import 'features/subscriptions/domain/usecases/restore_wallet_purchases.dart';
import 'features/ads/domain/usecases/show_post_add_card_monetization.dart';
import 'core/l10n/locale_preference_material.dart';
import 'features/settings/domain/entities/locale_preference.dart';
import 'features/settings/domain/entities/theme_preference.dart';
import 'features/settings/domain/usecases/get_locale_preference.dart';
import 'features/settings/domain/usecases/get_theme_preference.dart';
import 'features/settings/domain/usecases/request_app_review.dart';
import 'features/settings/domain/usecases/set_locale_preference.dart';
import 'features/settings/domain/usecases/set_theme_preference.dart';
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
    required this.loginWithEmail,
    required this.loginWithPhone,
    required this.loginWithLinkedIn,
    required this.registerUser,
    required this.getLastLoginCredentials,
    required this.forgotPassword,
    required this.resetPassword,
    required this.getCurrentUser,
    required this.logout,
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
    required this.initialThemePreference,
    required this.getLocalePreference,
    required this.setLocalePreference,
    required this.initialLocalePreference,
    required this.submitSupportRequest,
    required this.requestAppReview,
    required this.getEventGroups,
    required this.createEventGroup,
    required this.deleteEventGroup,
    required this.linkEventGroupCards,
    required this.linkSavedCardsToEventGroup,
    required this.getSavedCards,
    required this.saveSavedCard,
    required this.getSavedCardsWalletQuota,
    required this.addSavedCard,
    required this.deleteSavedCard,
    required this.trackSavedCardContactClick,
    required this.upgradeWalletPlan,
    required this.restoreWalletPurchases,
    required this.getProfileStats,
    required this.getPlanEntitlements,
    required this.getNetworkGraph,
    required this.getNetworkGraphPath,
    required this.showPostAddCardMonetization,
  });

  final GlobalKey<NavigatorState> rootNavigatorKey;
  final RestoreAuthSession restoreAuthSession;
  final GetAuthSession getAuthSession;
  final IdentifySubscriptionUser identifySubscriptionUser;
  final LoginWithEmail loginWithEmail;
  final LoginWithPhone loginWithPhone;
  final LoginWithLinkedIn loginWithLinkedIn;
  final RegisterUser registerUser;
  final GetLastLoginCredentials getLastLoginCredentials;
  final ForgotPassword forgotPassword;
  final ResetPassword resetPassword;
  final GetCurrentUser getCurrentUser;
  final Logout logout;
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
  final ThemePreference initialThemePreference;
  final GetLocalePreference getLocalePreference;
  final SetLocalePreference setLocalePreference;
  final LocalePreference initialLocalePreference;
  final SubmitSupportRequest submitSupportRequest;
  final RequestAppReview requestAppReview;
  final GetEventGroups getEventGroups;
  final CreateEventGroup createEventGroup;
  final DeleteEventGroup deleteEventGroup;
  final LinkEventGroupCards linkEventGroupCards;
  final LinkSavedCardsToEventGroup linkSavedCardsToEventGroup;
  final GetSavedCards getSavedCards;
  final SaveSavedCard saveSavedCard;
  final GetSavedCardsWalletQuota getSavedCardsWalletQuota;
  final AddSavedCard addSavedCard;
  final DeleteSavedCard deleteSavedCard;
  final TrackSavedCardContactClick trackSavedCardContactClick;
  final UpgradeWalletPlan upgradeWalletPlan;
  final RestoreWalletPurchases restoreWalletPurchases;
  final GetProfileStats getProfileStats;
  final GetPlanEntitlements getPlanEntitlements;
  final GetNetworkGraph getNetworkGraph;
  final GetNetworkGraphPath getNetworkGraphPath;
  final ShowPostAddCardMonetization showPostAddCardMonetization;

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  _AppDestination _destination = _AppDestination.loading;
  late ThemePreference _themePreference;
  late LocalePreference _localePreference;
  bool _showPostOnboardingPaywall = false;

  @override
  void initState() {
    super.initState();
    _themePreference = widget.initialThemePreference;
    _localePreference = widget.initialLocalePreference;
    SessionExpiredHandler.instance.configure(
      navigatorKey: widget.rootNavigatorKey,
      onForceLogout: _onLogout,
    );
    _bootstrap();
    _loadTheme();
    _loadLocale();
  }

  Future<void> _bootstrap() async {
    final restored = await widget.restoreAuthSession();
    if (!mounted) return;

    if (!restored.isAuthenticated) {
      setState(() => _destination = _AppDestination.login);
      return;
    }

    final onboardingDone = restored.onboardingCompleted == true;
    await widget.syncOnboardingFromServer(completed: onboardingDone);

    setState(() {
      _destination =
          onboardingDone ? _AppDestination.main : _AppDestination.login;
    });
  }

  Future<void> _syncOnboardingFromProfile() async {
    try {
      final profile = await widget.getCurrentUser();
      await widget.syncOnboardingFromServer(
        completed: profile.onboardingCompleted,
      );
    } catch (_) {}
  }

  Future<void> _resolvePostLoginDestination() async {
    await _syncOnboardingFromProfile();

    final completed = await widget.getOnboardingCompleted();
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

  void _onLoginSuccess() {
    _identifySubscriptionUser();
    _resolvePostLoginDestination();
  }

  Future<void> _identifySubscriptionUser() async {
    final session = await widget.getAuthSession();
    if (session == null || session.userId.isEmpty) return;
    await widget.identifySubscriptionUser(session.userId);
  }

  void _onOnboardingFinish() {
    setState(() {
      _showPostOnboardingPaywall = true;
      _destination = _AppDestination.main;
    });
  }

  Future<void> _onLogout() async {
    await widget.logout();
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
          onFinish: _onOnboardingFinish,
        );
      case _AppDestination.main:
        return MainShellPage(
          showPostOnboardingPaywall: _showPostOnboardingPaywall,
          getOnboardingDraftCard: widget.getOnboardingDraftCard,
          getOnboardingDraftCards: widget.getOnboardingDraftCards,
          persistOnboardingCard: widget.persistOnboardingCard,
          getEventGroups: widget.getEventGroups,
          createEventGroup: widget.createEventGroup,
          deleteEventGroup: widget.deleteEventGroup,
          linkEventGroupCards: widget.linkEventGroupCards,
          linkSavedCardsToEventGroup: widget.linkSavedCardsToEventGroup,
          getSavedCards: widget.getSavedCards,
          saveSavedCard: widget.saveSavedCard,
          getSavedCardsWalletQuota: widget.getSavedCardsWalletQuota,
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
          uploadProfilePhoto: widget.uploadProfilePhoto,
          submitSupportRequest: widget.submitSupportRequest,
          requestAppReview: widget.requestAppReview,
          getProfileStats: widget.getProfileStats,
          showPostAddCardMonetization: widget.showPostAddCardMonetization,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
        return ChuckFabOverlay(
          child: child ?? const SizedBox.shrink(),
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
            CardenceConnectAnimation(
              size: 220,
              repeat: true,
              logoAssetPath: SplashTheme.darkLogoAsset,
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
