import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../firebase_options.dart';
import '../../features/event_groups/data/datasources/event_group_local_datasource.dart';
import '../../features/event_groups/data/repositories/event_group_repository_impl.dart';
import '../../features/event_groups/domain/usecases/get_event_groups.dart';
import '../../features/event_groups/domain/usecases/save_event_groups.dart';
import '../../features/onboarding/data/datasources/onboarding_local_datasource.dart';
import '../../features/onboarding/data/repositories/onboarding_repository_impl.dart';
import '../../features/onboarding/domain/usecases/complete_onboarding.dart';
import '../../features/onboarding/domain/usecases/get_onboarding_completed.dart';
import '../../features/onboarding/domain/usecases/get_onboarding_draft_card.dart';
import '../../features/onboarding/domain/usecases/get_onboarding_draft_cards.dart';
import '../../features/onboarding/domain/usecases/save_onboarding_draft_card.dart';
import '../../features/saved_cards/data/datasources/saved_card_local_datasource.dart';
import '../../features/saved_cards/data/datasources/wallet_entitlement_local_datasource.dart';
import '../../features/saved_cards/data/repositories/saved_card_repository_impl.dart';
import '../../features/saved_cards/data/repositories/wallet_entitlement_repository_impl.dart';
import '../../features/saved_cards/domain/usecases/add_saved_card.dart';
import '../../features/saved_cards/domain/usecases/get_saved_cards.dart';
import '../../features/saved_cards/domain/usecases/get_saved_cards_wallet_quota.dart';
import '../../features/saved_cards/domain/usecases/save_saved_card.dart';
import '../../features/saved_cards/domain/usecases/upgrade_wallet_plan.dart';
import '../../features/settings/data/datasources/theme_local_datasource.dart';
import '../../features/settings/data/repositories/theme_repository_impl.dart';
import '../../features/settings/domain/usecases/get_theme_preference.dart';
import '../../features/settings/domain/usecases/set_theme_preference.dart';

/// Uygulama açılışında çalıştırılacak tüm init işlemleri ve sonuçları.
/// main() içinde [AppInit.init] çağrılır; dönen [AppInitResult] ile [App] başlatılır.
class AppInit {
  AppInit._();

  /// Tüm bağımlılıkları ve servisleri başlatır. Uygulama açılmadan önce tek sefer çağrılmalı.
  static Future<AppInitResult> init() async {
    WidgetsFlutterBinding.ensureInitialized();
    await _initFirebase();
    final prefs = await _initSharedPreferences();
    final onboarding = _initOnboarding(prefs);
    final theme = _initTheme(prefs);

    final eventGroups = _initEventGroups(prefs);
    final savedCards = _initSavedCards(prefs);
    return AppInitResult(
      getOnboardingCompleted: onboarding.getOnboardingCompleted,
      completeOnboarding: onboarding.completeOnboarding,
      saveOnboardingDraftCard: onboarding.saveOnboardingDraftCard,
      getOnboardingDraftCard: onboarding.getOnboardingDraftCard,
      getOnboardingDraftCards: onboarding.getOnboardingDraftCards,
      getThemePreference: theme.getThemePreference,
      setThemePreference: theme.setThemePreference,
      getEventGroups: eventGroups.getEventGroups,
      saveEventGroups: eventGroups.saveEventGroups,
      getSavedCards: savedCards.getSavedCards,
      saveSavedCard: savedCards.saveSavedCard,
      getSavedCardsWalletQuota: savedCards.getSavedCardsWalletQuota,
      addSavedCard: savedCards.addSavedCard,
      upgradeWalletPlan: savedCards.upgradeWalletPlan,
    );
  }

  static ({
    GetSavedCards getSavedCards,
    SaveSavedCard saveSavedCard,
    GetSavedCardsWalletQuota getSavedCardsWalletQuota,
    AddSavedCard addSavedCard,
    UpgradeWalletPlan upgradeWalletPlan,
  }) _initSavedCards(SharedPreferences prefs) {
    final local = SavedCardLocalDataSourceImpl(prefs);
    final repo = SavedCardRepositoryImpl(local);
    final walletLocal = WalletEntitlementLocalDataSourceImpl(prefs);
    final walletRepo = WalletEntitlementRepositoryImpl(walletLocal);
    final getQuota = GetSavedCardsWalletQuota(repo, walletRepo);
    return (
      getSavedCards: GetSavedCards(repo),
      saveSavedCard: SaveSavedCard(repo),
      getSavedCardsWalletQuota: getQuota,
      addSavedCard: AddSavedCard(repo, getQuota),
      upgradeWalletPlan: UpgradeWalletPlan(walletRepo),
    );
  }

  static ({
    GetEventGroups getEventGroups,
    SaveEventGroups saveEventGroups,
  }) _initEventGroups(SharedPreferences prefs) {
    final local = EventGroupLocalDataSourceImpl(prefs);
    final repo = EventGroupRepositoryImpl(local);
    return (
      getEventGroups: GetEventGroups(repo),
      saveEventGroups: SaveEventGroups(repo),
    );
  }

  static Future<void> _initFirebase() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  static Future<SharedPreferences> _initSharedPreferences() async {
    return SharedPreferences.getInstance();
  }

  static ({
    GetOnboardingCompleted getOnboardingCompleted,
    CompleteOnboarding completeOnboarding,
    SaveOnboardingDraftCard saveOnboardingDraftCard,
    GetOnboardingDraftCard getOnboardingDraftCard,
    GetOnboardingDraftCards getOnboardingDraftCards,
  }) _initOnboarding(SharedPreferences prefs) {
    final local = OnboardingLocalDataSourceImpl(prefs);
    final repo = OnboardingRepositoryImpl(local);
    return (
      getOnboardingCompleted: GetOnboardingCompleted(repo),
      completeOnboarding: CompleteOnboarding(repo),
      saveOnboardingDraftCard: SaveOnboardingDraftCard(repo),
      getOnboardingDraftCard: GetOnboardingDraftCard(repo),
      getOnboardingDraftCards: GetOnboardingDraftCards(repo),
    );
  }

  static ({
    GetThemePreference getThemePreference,
    SetThemePreference setThemePreference,
  }) _initTheme(SharedPreferences prefs) {
    final local = ThemeLocalDataSourceImpl(prefs);
    final repo = ThemeRepositoryImpl(local);
    return (
      getThemePreference: GetThemePreference(repo),
      setThemePreference: SetThemePreference(repo),
    );
  }
}

/// [AppInit.init] sonucu; [App] ve gerekirse diğer yerler tarafından kullanılır.
class AppInitResult {
  const AppInitResult({
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
}
