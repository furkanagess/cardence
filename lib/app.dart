import 'package:flutter/material.dart';

import 'core/constants/app_constants.dart';
import 'core/network/interceptors/chuck_interceptor_service.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/molecules/chuck_fab_overlay.dart';
import 'core/widgets/organisms/cardence_scaffold.dart';
import 'features/auth/domain/usecases/forgot_password.dart';
import 'features/auth/domain/usecases/get_current_user.dart';
import 'features/auth/domain/usecases/login_with_email.dart';
import 'features/auth/domain/usecases/login_with_phone.dart';
import 'features/auth/domain/usecases/logout.dart';
import 'features/auth/domain/usecases/register_user.dart';
import 'features/auth/domain/usecases/reset_password.dart';
import 'features/auth/domain/usecases/restore_auth_session.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/event_groups/domain/usecases/get_event_groups.dart';
import 'features/event_groups/domain/usecases/save_event_groups.dart';
import 'features/onboarding/domain/usecases/get_onboarding_completed.dart';
import 'features/onboarding/domain/usecases/get_onboarding_draft_card.dart';
import 'features/onboarding/domain/usecases/get_onboarding_draft_cards.dart';
import 'features/onboarding/domain/usecases/resolve_onboarding_initial_draft.dart';
import 'features/business_cards/domain/usecases/persist_onboarding_card.dart';
import 'features/business_cards/domain/usecases/save_business_card.dart';
import 'features/onboarding/domain/usecases/sync_onboarding_from_server.dart';
import 'features/onboarding/presentation/pages/onboarding_page.dart';
import 'features/saved_cards/domain/usecases/add_saved_card.dart';
import 'features/saved_cards/domain/usecases/delete_saved_card.dart';
import 'features/saved_cards/domain/usecases/get_saved_cards.dart';
import 'features/saved_cards/domain/usecases/get_saved_cards_wallet_quota.dart';
import 'features/saved_cards/domain/usecases/save_saved_card.dart';
import 'features/saved_cards/domain/usecases/upgrade_wallet_plan.dart';
import 'features/settings/domain/entities/theme_preference.dart';
import 'features/settings/domain/usecases/get_theme_preference.dart';
import 'features/settings/domain/usecases/set_theme_preference.dart';
import 'features/shell/presentation/pages/main_shell_page.dart';

enum _AppDestination { loading, login, onboarding, main }

/// Uygulama kökü: login → onboarding → ana kabuk.
class App extends StatefulWidget {
  const App({
    super.key,
    required this.restoreAuthSession,
    required this.loginWithEmail,
    required this.loginWithPhone,
    required this.registerUser,
    required this.forgotPassword,
    required this.resetPassword,
    required this.getCurrentUser,
    required this.logout,
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
    required this.getEventGroups,
    required this.saveEventGroups,
    required this.getSavedCards,
    required this.saveSavedCard,
    required this.getSavedCardsWalletQuota,
    required this.addSavedCard,
    required this.deleteSavedCard,
    required this.upgradeWalletPlan,
  });

  final RestoreAuthSession restoreAuthSession;
  final LoginWithEmail loginWithEmail;
  final LoginWithPhone loginWithPhone;
  final RegisterUser registerUser;
  final ForgotPassword forgotPassword;
  final ResetPassword resetPassword;
  final GetCurrentUser getCurrentUser;
  final Logout logout;
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
  final GetEventGroups getEventGroups;
  final SaveEventGroups saveEventGroups;
  final GetSavedCards getSavedCards;
  final SaveSavedCard saveSavedCard;
  final GetSavedCardsWalletQuota getSavedCardsWalletQuota;
  final AddSavedCard addSavedCard;
  final DeleteSavedCard deleteSavedCard;
  final UpgradeWalletPlan upgradeWalletPlan;

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  _AppDestination _destination = _AppDestination.loading;
  ThemePreference _themePreference = ThemePreference.system;

  @override
  void initState() {
    super.initState();
    _bootstrap();
    _loadTheme();
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

  void _onLoginSuccess() {
    _resolvePostLoginDestination();
  }

  void _onOnboardingFinish() {
    setState(() => _destination = _AppDestination.main);
  }

  Future<void> _onLogout() async {
    await widget.logout();
    await widget.syncOnboardingFromServer(completed: false);
    if (!mounted) return;
    setState(() => _destination = _AppDestination.login);
  }

  void _onThemeChanged(ThemePreference preference) async {
    await widget.setThemePreference(preference);
    if (!mounted) return;
    setState(() => _themePreference = preference);
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
          registerUser: widget.registerUser,
          forgotPassword: widget.forgotPassword,
          resetPassword: widget.resetPassword,
          onLoginSuccess: _onLoginSuccess,
        );
      case _AppDestination.onboarding:
        return OnboardingPageView(
          completeOnboarding: widget.completeOnboarding,
          resolveInitialDraft: widget.resolveOnboardingInitialDraft,
          persistOnboardingCard: widget.persistOnboardingCard,
          onFinish: _onOnboardingFinish,
        );
      case _AppDestination.main:
        return MainShellPage(
          getOnboardingDraftCard: widget.getOnboardingDraftCard,
          getOnboardingDraftCards: widget.getOnboardingDraftCards,
          persistOnboardingCard: widget.persistOnboardingCard,
          getEventGroups: widget.getEventGroups,
          saveEventGroups: widget.saveEventGroups,
          getSavedCards: widget.getSavedCards,
          saveSavedCard: widget.saveSavedCard,
          getSavedCardsWalletQuota: widget.getSavedCardsWalletQuota,
          addSavedCard: widget.addSavedCard,
          deleteSavedCard: widget.deleteSavedCard,
          upgradeWalletPlan: widget.upgradeWalletPlan,
          themePreference: _themePreference,
          onThemeChanged: _onThemeChanged,
          onLogout: _onLogout,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: ChuckInterceptorService.instance.navigatorKey,
      title: 'Cardence',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _themeMode,
      debugShowCheckedModeBanner: false,
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

    return CardenceScaffold(
      showWatermark: false,
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              isDark
                  ? 'assets/icons/cardence_logo_splash_white.png'
                  : 'assets/icons/cardence_logo-removebg.png',
              width: 120,
              height: 120,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              AppConstants.appName,
              style: theme.textTheme.headlineSmall?.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              AppConstants.appTagline,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
