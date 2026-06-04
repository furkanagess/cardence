import 'package:flutter/material.dart';

import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/organisms/cardence_scaffold.dart';
import 'features/onboarding/domain/usecases/complete_onboarding.dart';
import 'features/onboarding/domain/usecases/get_onboarding_completed.dart';
import 'features/onboarding/domain/usecases/get_onboarding_draft_card.dart';
import 'features/onboarding/domain/usecases/get_onboarding_draft_cards.dart';
import 'features/event_groups/domain/usecases/get_event_groups.dart';
import 'features/event_groups/domain/usecases/save_event_groups.dart';
import 'features/saved_cards/domain/usecases/add_saved_card.dart';
import 'features/saved_cards/domain/usecases/get_saved_cards.dart';
import 'features/saved_cards/domain/usecases/get_saved_cards_wallet_quota.dart';
import 'features/saved_cards/domain/usecases/save_saved_card.dart';
import 'features/saved_cards/domain/usecases/upgrade_wallet_plan.dart';
import 'features/onboarding/domain/usecases/save_onboarding_draft_card.dart';
import 'features/onboarding/presentation/pages/onboarding_page.dart';
import 'features/settings/domain/entities/theme_preference.dart';
import 'features/settings/domain/usecases/get_theme_preference.dart';
import 'features/settings/domain/usecases/set_theme_preference.dart';
import 'features/shell/presentation/pages/main_shell_page.dart';

/// Uygulama kökü: onboarding, tema, bottom nav ile ana kabuk.
class App extends StatefulWidget {
  const App({
    super.key,
    required this.getOnboardingCompleted,
    required this.completeOnboarding,
    required this.saveOnboardingDraftCard,
    required this.getOnboardingDraftCard,
    required this.getOnboardingDraftCards,
    required this.getThemePreference,
    required this.setThemePreference,
    required this.getEventGroups,
    required this.saveEventGroups,
    required this.getSavedCards,
    required this.saveSavedCard,
    required this.getSavedCardsWalletQuota,
    required this.addSavedCard,
    required this.upgradeWalletPlan,
  });

  final GetOnboardingCompleted getOnboardingCompleted;
  final CompleteOnboarding completeOnboarding;
  final SaveOnboardingDraftCard saveOnboardingDraftCard;
  final GetOnboardingDraftCard getOnboardingDraftCard;
  final GetOnboardingDraftCards getOnboardingDraftCards;
  final GetThemePreference getThemePreference;
  final SetThemePreference setThemePreference;
  final GetEventGroups getEventGroups;
  final SaveEventGroups saveEventGroups;
  final GetSavedCards getSavedCards;
  final SaveSavedCard saveSavedCard;
  final GetSavedCardsWalletQuota getSavedCardsWalletQuota;
  final AddSavedCard addSavedCard;
  final UpgradeWalletPlan upgradeWalletPlan;

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  bool _isLoading = true;
  bool _showOnboarding = true;
  ThemePreference _themePreference = ThemePreference.system;

  @override
  void initState() {
    super.initState();
    _checkOnboarding();
    _loadTheme();
  }

  Future<void> _checkOnboarding() async {
    final completed = await widget.getOnboardingCompleted();
    if (!mounted) return;
    setState(() {
      _isLoading = false;
      _showOnboarding = !completed;
    });
  }

  Future<void> _loadTheme() async {
    final pref = await widget.getThemePreference();
    if (!mounted) return;
    setState(() => _themePreference = pref);
  }

  void _onOnboardingFinish() {
    setState(() => _showOnboarding = false);
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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cardence',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _themeMode,
      debugShowCheckedModeBanner: false,
      home: _isLoading
          ? const _SplashContent()
          : _showOnboarding
              ? OnboardingPageView(
                  completeOnboarding: widget.completeOnboarding,
                  saveOnboardingDraftCard: widget.saveOnboardingDraftCard,
                  onFinish: _onOnboardingFinish,
                )
              : MainShellPage(
                  getOnboardingDraftCard: widget.getOnboardingDraftCard,
                  getOnboardingDraftCards: widget.getOnboardingDraftCards,
                  saveOnboardingDraftCard: widget.saveOnboardingDraftCard,
                  getEventGroups: widget.getEventGroups,
                  saveEventGroups: widget.saveEventGroups,
                  getSavedCards: widget.getSavedCards,
                  saveSavedCard: widget.saveSavedCard,
                  getSavedCardsWalletQuota: widget.getSavedCardsWalletQuota,
                  addSavedCard: widget.addSavedCard,
                  upgradeWalletPlan: widget.upgradeWalletPlan,
                  themePreference: _themePreference,
                  onThemeChanged: _onThemeChanged,
                ),
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
