import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../firebase_options.dart';
import '../../features/auth/data/datasources/auth_local_datasource.dart';
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/entities/user_profile.dart';
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
import '../../features/auth/domain/usecases/upload_profile_photo.dart';
import '../../features/business_cards/data/datasources/business_card_remote_datasource.dart';
import '../../features/business_cards/data/repositories/business_card_repository_impl.dart';
import '../../features/business_cards/domain/usecases/get_business_cards.dart';
import '../../features/business_cards/domain/usecases/persist_onboarding_card.dart';
import '../../features/business_cards/domain/usecases/save_business_card.dart';
import '../../features/business_cards/domain/usecases/upsert_business_card.dart';
import 'complete_onboarding_flow.dart';
import '../../features/event_groups/data/datasources/event_group_local_datasource.dart';
import '../../features/event_groups/data/repositories/event_group_repository_impl.dart';
import '../../features/event_groups/domain/usecases/get_event_groups.dart';
import '../../features/event_groups/data/datasources/event_group_remote_datasource.dart';
import '../../features/event_groups/domain/usecases/create_event_group.dart';
import '../../features/event_groups/domain/usecases/delete_event_group.dart';
import '../../features/event_groups/domain/usecases/link_event_group_cards.dart';
import '../../features/onboarding/data/datasources/onboarding_local_datasource.dart';
import '../../features/onboarding/data/repositories/onboarding_repository_impl.dart';
import '../../features/onboarding/domain/usecases/complete_onboarding.dart';
import '../../features/onboarding/domain/usecases/get_onboarding_completed.dart';
import '../../features/onboarding/domain/usecases/sync_onboarding_from_server.dart';
import '../../features/onboarding/domain/usecases/get_onboarding_draft_card.dart';
import '../../features/onboarding/domain/usecases/get_onboarding_draft_cards.dart';
import '../../features/onboarding/domain/usecases/resolve_onboarding_initial_draft.dart';
import '../../features/onboarding/domain/usecases/save_onboarding_draft_card.dart';
import '../../features/saved_cards/data/datasources/saved_card_local_datasource.dart';
import '../../features/saved_cards/data/datasources/saved_card_remote_datasource.dart';
import '../../features/saved_cards/data/datasources/wallet_entitlement_local_datasource.dart';
import '../../features/saved_cards/data/repositories/saved_card_repository_impl.dart';
import '../../features/saved_cards/data/repositories/wallet_entitlement_repository_impl.dart';
import '../../features/saved_cards/domain/usecases/add_saved_card.dart';
import '../../features/saved_cards/domain/usecases/link_saved_cards_to_event_group.dart';
import '../../features/saved_cards/domain/usecases/delete_saved_card.dart';
import '../../features/saved_cards/domain/usecases/get_saved_cards.dart';
import '../../features/saved_cards/domain/usecases/get_saved_cards_wallet_quota.dart';
import '../../features/saved_cards/domain/usecases/save_saved_card.dart';
import '../../features/saved_cards/domain/usecases/upgrade_wallet_plan.dart';
import '../../features/settings/data/datasources/theme_local_datasource.dart';
import '../../features/settings/data/repositories/theme_repository_impl.dart';
import '../../features/settings/domain/usecases/get_theme_preference.dart';
import '../../features/settings/domain/usecases/set_theme_preference.dart';
import '../../features/support/data/datasources/support_remote_datasource.dart';
import '../../features/support/data/repositories/support_repository_impl.dart';
import '../../features/support/domain/usecases/submit_support_request.dart';
import '../user_data/clear_user_scoped_local_data.dart';
import '../user_data/sync_user_profile_cards.dart';

/// Uygulama açılışında çalıştırılacak tüm init işlemleri ve sonuçları.
/// main() içinde [AppInit.init] çağrılır; dönen [AppInitResult] ile [App] başlatılır.
class AppInit {
  AppInit._();

  /// Tüm bağımlılıkları ve servisleri başlatır. Uygulama açılmadan önce tek sefer çağrılmalı.
  static Future<AppInitResult> init() async {
    WidgetsFlutterBinding.ensureInitialized();
    await _initFirebase();
    final prefs = await _initSharedPreferences();
    final authLocal = AuthLocalDataSourceImpl(prefs);

    final onboardingLocal = OnboardingLocalDataSourceImpl(prefs, authLocal);
    final onboardingRepo = OnboardingRepositoryImpl(onboardingLocal);
    final syncOnboardingFromServer = SyncOnboardingFromServer(onboardingRepo);

    final savedCardLocal = SavedCardLocalDataSourceImpl(prefs, authLocal);
    final savedCardRepo = SavedCardRepositoryImpl(
      local: savedCardLocal,
      remote: SavedCardRemoteDataSourceImpl(),
      authLocal: authLocal,
    );
    final walletLocal = WalletEntitlementLocalDataSourceImpl(prefs);
    final walletRepo = WalletEntitlementRepositoryImpl(walletLocal);
    final eventGroupLocal = EventGroupLocalDataSourceImpl(prefs, authLocal);

    final syncUserProfileCards = SyncUserProfileCards(
      savedCardRepo,
      onboardingRepo,
      syncOnboardingFromServer,
    );
    final clearUserScopedLocalData = ClearUserScopedLocalData(
      authLocal: authLocal,
      savedCardLocal: savedCardLocal,
      onboardingLocal: onboardingLocal,
      eventGroupLocal: eventGroupLocal,
      prefs: prefs,
    );

    final auth = _initAuth(
      authLocal: authLocal,
      onProfileSynced: syncUserProfileCards.call,
      onLogout: () => clearUserScopedLocalData(),
    );
    final businessCards = _initBusinessCards(prefs, authLocal);
    final onboarding = _initOnboarding(
      onboardingRepo: onboardingRepo,
      syncOnboardingFromServer: syncOnboardingFromServer,
      completeOnboardingRemote: auth.completeOnboardingRemote,
      getCurrentUser: auth.getCurrentUser,
    );
    final persistOnboardingCard = PersistOnboardingCard(
      onboarding.saveOnboardingDraftCard,
      businessCards.upsertBusinessCard,
    );
    final theme = _initTheme(prefs);
    final support = _initSupport(authLocal);

    final eventGroups = _initEventGroups(
      local: eventGroupLocal,
      authLocal: authLocal,
    );
    final savedCards = _initSavedCards(
      savedCardRepo: savedCardRepo,
      walletRepo: walletRepo,
    );
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
      uploadProfilePhoto: auth.uploadProfilePhoto,
      getOnboardingCompleted: onboarding.getOnboardingCompleted,
      completeOnboarding: onboarding.completeOnboarding,
      syncOnboardingFromServer: onboarding.syncOnboardingFromServer,
      saveOnboardingDraftCard: onboarding.saveOnboardingDraftCard,
      persistOnboardingCard: persistOnboardingCard,
      saveBusinessCard: businessCards.saveBusinessCard,
      getOnboardingDraftCard: onboarding.getOnboardingDraftCard,
      getOnboardingDraftCards: onboarding.getOnboardingDraftCards,
      resolveOnboardingInitialDraft: onboarding.resolveOnboardingInitialDraft,
      getThemePreference: theme.getThemePreference,
      setThemePreference: theme.setThemePreference,
      submitSupportRequest: support.submitSupportRequest,
      getEventGroups: eventGroups.getEventGroups,
      createEventGroup: eventGroups.createEventGroup,
      deleteEventGroup: eventGroups.deleteEventGroup,
      linkEventGroupCards: eventGroups.linkEventGroupCards,
      getSavedCards: savedCards.getSavedCards,
      saveSavedCard: savedCards.saveSavedCard,
      getSavedCardsWalletQuota: savedCards.getSavedCardsWalletQuota,
      addSavedCard: savedCards.addSavedCard,
      deleteSavedCard: savedCards.deleteSavedCard,
      upgradeWalletPlan: savedCards.upgradeWalletPlan,
      linkSavedCardsToEventGroup: savedCards.linkSavedCardsToEventGroup,
    );
  }

  static ({
    GetSavedCards getSavedCards,
    SaveSavedCard saveSavedCard,
    GetSavedCardsWalletQuota getSavedCardsWalletQuota,
    AddSavedCard addSavedCard,
    DeleteSavedCard deleteSavedCard,
    UpgradeWalletPlan upgradeWalletPlan,
    LinkSavedCardsToEventGroup linkSavedCardsToEventGroup,
  }) _initSavedCards({
    required SavedCardRepositoryImpl savedCardRepo,
    required WalletEntitlementRepositoryImpl walletRepo,
  }) {
    final getQuota = GetSavedCardsWalletQuota(savedCardRepo);
    final saveSavedCard = SaveSavedCard(savedCardRepo);
    return (
      getSavedCards: GetSavedCards(savedCardRepo),
      saveSavedCard: saveSavedCard,
      getSavedCardsWalletQuota: getQuota,
      addSavedCard: AddSavedCard(savedCardRepo),
      deleteSavedCard: DeleteSavedCard(savedCardRepo),
      upgradeWalletPlan: UpgradeWalletPlan(walletRepo),
      linkSavedCardsToEventGroup: LinkSavedCardsToEventGroup(saveSavedCard),
    );
  }

  static ({
    GetEventGroups getEventGroups,
    CreateEventGroup createEventGroup,
    DeleteEventGroup deleteEventGroup,
    LinkEventGroupCards linkEventGroupCards,
  }) _initEventGroups({
    required EventGroupLocalDataSource local,
    required AuthLocalDataSource authLocal,
  }) {
    final repo = EventGroupRepositoryImpl(
      local: local,
      remote: EventGroupRemoteDataSourceImpl(),
      authLocal: authLocal,
    );
    return (
      getEventGroups: GetEventGroups(repo),
      createEventGroup: CreateEventGroup(repo),
      deleteEventGroup: DeleteEventGroup(repo),
      linkEventGroupCards: LinkEventGroupCards(repo),
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
    UploadProfilePhoto uploadProfilePhoto,
    CompleteOnboardingRemote completeOnboardingRemote,
  }) _initAuth({
    required AuthLocalDataSource authLocal,
    required Future<void> Function(UserProfile profile) onProfileSynced,
    required Future<void> Function() onLogout,
  }) {
    final remote = AuthRemoteDataSourceImpl();
    final repo = AuthRepositoryImpl(
      remote: remote,
      local: authLocal,
      onProfileSynced: onProfileSynced,
      onLogout: onLogout,
    );
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
      uploadProfilePhoto: UploadProfilePhoto(repo),
      completeOnboardingRemote: CompleteOnboardingRemote(repo),
    );
  }

  static ({
    SaveBusinessCard saveBusinessCard,
    GetBusinessCards getBusinessCards,
    UpsertBusinessCard upsertBusinessCard,
  }) _initBusinessCards(
    SharedPreferences prefs,
    AuthLocalDataSource authLocal,
  ) {
    final remote = BusinessCardRemoteDataSourceImpl();
    final repo = BusinessCardRepositoryImpl(
      remote: remote,
      authLocal: authLocal,
    );
    return (
      saveBusinessCard: SaveBusinessCard(repo),
      getBusinessCards: GetBusinessCards(repo),
      upsertBusinessCard: UpsertBusinessCard(repo),
    );
  }

  static ({
    GetOnboardingCompleted getOnboardingCompleted,
    Future<void> Function() completeOnboarding,
    SyncOnboardingFromServer syncOnboardingFromServer,
    SaveOnboardingDraftCard saveOnboardingDraftCard,
    GetOnboardingDraftCard getOnboardingDraftCard,
    GetOnboardingDraftCards getOnboardingDraftCards,
    ResolveOnboardingInitialDraft resolveOnboardingInitialDraft,
  }) _initOnboarding({
    required OnboardingRepositoryImpl onboardingRepo,
    required SyncOnboardingFromServer syncOnboardingFromServer,
    required CompleteOnboardingRemote completeOnboardingRemote,
    required GetCurrentUser getCurrentUser,
  }) {
    final repo = onboardingRepo;
    final flow = CompleteOnboardingFlow(
      local: CompleteOnboarding(repo),
      remote: completeOnboardingRemote,
    );
    final getDraftCard = GetOnboardingDraftCard(repo);
    return (
      getOnboardingCompleted: GetOnboardingCompleted(repo),
      completeOnboarding: flow.call,
      syncOnboardingFromServer: SyncOnboardingFromServer(repo),
      saveOnboardingDraftCard: SaveOnboardingDraftCard(repo),
      getOnboardingDraftCard: getDraftCard,
      getOnboardingDraftCards: GetOnboardingDraftCards(repo),
      resolveOnboardingInitialDraft: ResolveOnboardingInitialDraft(
        getDraftCard,
        getCurrentUser,
      ),
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

  static ({SubmitSupportRequest submitSupportRequest}) _initSupport(
    AuthLocalDataSource authLocal,
  ) {
    final repo = SupportRepositoryImpl(
      remote: SupportRemoteDataSourceImpl(),
      authLocal: authLocal,
    );
    return (
      submitSupportRequest: SubmitSupportRequest(repo),
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
    required this.uploadProfilePhoto,
    required this.getOnboardingCompleted,
    required this.completeOnboarding,
    required this.syncOnboardingFromServer,
    required this.saveOnboardingDraftCard,
    required this.persistOnboardingCard,
    required this.saveBusinessCard,
    required this.getOnboardingDraftCard,
    required this.getOnboardingDraftCards,
    required this.resolveOnboardingInitialDraft,
    required this.getThemePreference,
    required this.setThemePreference,
    required this.submitSupportRequest,
    required this.getEventGroups,
    required this.createEventGroup,
    required this.deleteEventGroup,
    required this.linkEventGroupCards,
    required this.getSavedCards,
    required this.saveSavedCard,
    required this.getSavedCardsWalletQuota,
    required this.addSavedCard,
    required this.deleteSavedCard,
    required this.upgradeWalletPlan,
    required this.linkSavedCardsToEventGroup,
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
  final UploadProfilePhoto uploadProfilePhoto;
  final GetOnboardingCompleted getOnboardingCompleted;
  final Future<void> Function() completeOnboarding;
  final SyncOnboardingFromServer syncOnboardingFromServer;
  final SaveOnboardingDraftCard saveOnboardingDraftCard;
  final PersistOnboardingCard persistOnboardingCard;
  final SaveBusinessCard saveBusinessCard;
  final GetOnboardingDraftCard getOnboardingDraftCard;
  final GetOnboardingDraftCards getOnboardingDraftCards;
  final ResolveOnboardingInitialDraft resolveOnboardingInitialDraft;
  final GetThemePreference getThemePreference;
  final SetThemePreference setThemePreference;
  final SubmitSupportRequest submitSupportRequest;
  final GetEventGroups getEventGroups;
  final CreateEventGroup createEventGroup;
  final DeleteEventGroup deleteEventGroup;
  final LinkEventGroupCards linkEventGroupCards;
  final GetSavedCards getSavedCards;
  final SaveSavedCard saveSavedCard;
  final GetSavedCardsWalletQuota getSavedCardsWalletQuota;
  final AddSavedCard addSavedCard;
  final DeleteSavedCard deleteSavedCard;
  final UpgradeWalletPlan upgradeWalletPlan;
  final LinkSavedCardsToEventGroup linkSavedCardsToEventGroup;
}
