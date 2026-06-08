import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../network/interceptors/chuck_interceptor_service.dart';
import '../../firebase_options.dart';
import '../../features/auth/data/datasources/auth_local_datasource.dart';
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/usecases/complete_onboarding_remote.dart';
import '../../features/auth/domain/usecases/forgot_password.dart';
import '../../features/auth/domain/usecases/get_auth_session.dart';
import '../../features/auth/domain/usecases/get_current_user.dart';
import '../../features/auth/domain/usecases/login_with_email.dart';
import '../../features/auth/domain/usecases/login_with_phone.dart';
import '../../features/auth/domain/usecases/logout.dart';
import '../../features/auth/domain/usecases/register_user.dart';
import '../../features/auth/domain/usecases/reset_password.dart';
import '../../features/auth/domain/usecases/restore_auth_session.dart';
import '../../features/business_cards/data/datasources/business_card_remote_datasource.dart';
import '../../features/business_cards/data/repositories/business_card_repository_impl.dart';
import '../../features/business_cards/domain/usecases/get_business_cards.dart';
import '../../features/business_cards/domain/usecases/save_business_card.dart';
import 'complete_onboarding_flow.dart';
import '../../features/event_groups/data/datasources/event_group_local_datasource.dart';
import '../../features/event_groups/data/repositories/event_group_repository_impl.dart';
import '../../features/event_groups/domain/usecases/get_event_groups.dart';
import '../../features/event_groups/domain/usecases/save_event_groups.dart';
import '../../features/onboarding/data/datasources/onboarding_local_datasource.dart';
import '../../features/onboarding/data/repositories/onboarding_repository_impl.dart';
import '../../features/onboarding/domain/usecases/complete_onboarding.dart';
import '../../features/onboarding/domain/usecases/get_onboarding_completed.dart';
import '../../features/onboarding/domain/usecases/sync_onboarding_from_server.dart';
import '../../features/onboarding/domain/usecases/get_onboarding_draft_card.dart';
import '../../features/onboarding/domain/usecases/get_onboarding_draft_cards.dart';
import '../../features/onboarding/domain/usecases/save_onboarding_draft_card.dart';
import '../../features/saved_cards/data/datasources/saved_card_local_datasource.dart';
import '../../features/saved_cards/data/datasources/saved_card_remote_datasource.dart';
import '../../features/saved_cards/data/datasources/wallet_entitlement_local_datasource.dart';
import '../../features/saved_cards/data/repositories/saved_card_repository_impl.dart';
import '../../features/saved_cards/data/repositories/wallet_entitlement_repository_impl.dart';
import '../../features/saved_cards/domain/usecases/add_saved_card.dart';
import '../../features/saved_cards/domain/usecases/delete_saved_card.dart';
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
    ChuckInterceptorService.instance.ensureInitialized();
    await _initFirebase();
    final prefs = await _initSharedPreferences();
    final auth = _initAuth(prefs);
    final businessCards = _initBusinessCards(prefs);
    final onboarding = _initOnboarding(prefs, auth.completeOnboardingRemote);
    final theme = _initTheme(prefs);

    final eventGroups = _initEventGroups(prefs);
    final savedCards = _initSavedCards(prefs);
    return AppInitResult(
      restoreAuthSession: auth.restoreAuthSession,
      getAuthSession: auth.getAuthSession,
      loginWithEmail: auth.loginWithEmail,
      loginWithPhone: auth.loginWithPhone,
      registerUser: auth.registerUser,
      forgotPassword: auth.forgotPassword,
      resetPassword: auth.resetPassword,
      getCurrentUser: auth.getCurrentUser,
      logout: auth.logout,
      getOnboardingCompleted: onboarding.getOnboardingCompleted,
      completeOnboarding: onboarding.completeOnboarding,
      syncOnboardingFromServer: onboarding.syncOnboardingFromServer,
      saveOnboardingDraftCard: onboarding.saveOnboardingDraftCard,
      saveBusinessCard: businessCards.saveBusinessCard,
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
      deleteSavedCard: savedCards.deleteSavedCard,
      upgradeWalletPlan: savedCards.upgradeWalletPlan,
    );
  }

  static ({
    GetSavedCards getSavedCards,
    SaveSavedCard saveSavedCard,
    GetSavedCardsWalletQuota getSavedCardsWalletQuota,
    AddSavedCard addSavedCard,
    DeleteSavedCard deleteSavedCard,
    UpgradeWalletPlan upgradeWalletPlan,
  }) _initSavedCards(SharedPreferences prefs) {
    final local = SavedCardLocalDataSourceImpl(prefs);
    final remote = SavedCardRemoteDataSourceImpl();
    final authLocal = AuthLocalDataSourceImpl(prefs);
    final repo = SavedCardRepositoryImpl(
      local: local,
      remote: remote,
      authLocal: authLocal,
    );
    final walletLocal = WalletEntitlementLocalDataSourceImpl(prefs);
    final walletRepo = WalletEntitlementRepositoryImpl(walletLocal);
    final getQuota = GetSavedCardsWalletQuota(repo);
    return (
      getSavedCards: GetSavedCards(repo),
      saveSavedCard: SaveSavedCard(repo),
      getSavedCardsWalletQuota: getQuota,
      addSavedCard: AddSavedCard(repo),
      deleteSavedCard: DeleteSavedCard(repo),
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
    RestoreAuthSession restoreAuthSession,
    GetAuthSession getAuthSession,
    LoginWithEmail loginWithEmail,
    LoginWithPhone loginWithPhone,
    RegisterUser registerUser,
    ForgotPassword forgotPassword,
    ResetPassword resetPassword,
    GetCurrentUser getCurrentUser,
    Logout logout,
    CompleteOnboardingRemote completeOnboardingRemote,
  }) _initAuth(SharedPreferences prefs) {
    final remote = AuthRemoteDataSourceImpl();
    final local = AuthLocalDataSourceImpl(prefs);
    final repo = AuthRepositoryImpl(remote: remote, local: local);
    return (
      restoreAuthSession: RestoreAuthSession(repo),
      getAuthSession: GetAuthSession(repo),
      loginWithEmail: LoginWithEmail(repo),
      loginWithPhone: LoginWithPhone(repo),
      registerUser: RegisterUser(repo),
      forgotPassword: ForgotPassword(repo),
      resetPassword: ResetPassword(repo),
      getCurrentUser: GetCurrentUser(repo),
      logout: Logout(repo),
      completeOnboardingRemote: CompleteOnboardingRemote(repo),
    );
  }

  static ({
    SaveBusinessCard saveBusinessCard,
    GetBusinessCards getBusinessCards,
  }) _initBusinessCards(
    SharedPreferences prefs,
  ) {
    final authLocal = AuthLocalDataSourceImpl(prefs);
    final remote = BusinessCardRemoteDataSourceImpl();
    final repo = BusinessCardRepositoryImpl(
      remote: remote,
      authLocal: authLocal,
    );
    return (
      saveBusinessCard: SaveBusinessCard(repo),
      getBusinessCards: GetBusinessCards(repo),
    );
  }

  static ({
    GetOnboardingCompleted getOnboardingCompleted,
    Future<void> Function() completeOnboarding,
    SyncOnboardingFromServer syncOnboardingFromServer,
    SaveOnboardingDraftCard saveOnboardingDraftCard,
    GetOnboardingDraftCard getOnboardingDraftCard,
    GetOnboardingDraftCards getOnboardingDraftCards,
  }) _initOnboarding(
    SharedPreferences prefs,
    CompleteOnboardingRemote completeOnboardingRemote,
  ) {
    final local = OnboardingLocalDataSourceImpl(prefs);
    final repo = OnboardingRepositoryImpl(local);
    final flow = CompleteOnboardingFlow(
      local: CompleteOnboarding(repo),
      remote: completeOnboardingRemote,
    );
    return (
      getOnboardingCompleted: GetOnboardingCompleted(repo),
      completeOnboarding: flow.call,
      syncOnboardingFromServer: SyncOnboardingFromServer(repo),
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
    required this.restoreAuthSession,
    required this.getAuthSession,
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
    required this.saveOnboardingDraftCard,
    required this.saveBusinessCard,
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
    required this.deleteSavedCard,
    required this.upgradeWalletPlan,
  });

  final RestoreAuthSession restoreAuthSession;
  final GetAuthSession getAuthSession;
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
  final SaveOnboardingDraftCard saveOnboardingDraftCard;
  final SaveBusinessCard saveBusinessCard;
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
  final DeleteSavedCard deleteSavedCard;
  final UpgradeWalletPlan upgradeWalletPlan;
}
