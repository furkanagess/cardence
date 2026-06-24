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
import '../../features/auth/domain/usecases/get_last_login_credentials.dart';
import '../../features/auth/domain/usecases/login_with_email.dart';
import '../../features/auth/domain/usecases/login_with_linkedin.dart';
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
import '../../features/profile/data/datasources/profile_remote_datasource.dart';
import '../../features/profile/data/repositories/profile_repository_impl.dart';
import '../../features/profile/domain/usecases/get_profile_stats.dart';
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
import '../../features/saved_cards/data/repositories/saved_card_repository_impl.dart';
import '../../features/saved_cards/domain/usecases/add_saved_card.dart';
import '../../features/saved_cards/domain/usecases/link_saved_cards_to_event_group.dart';
import '../../features/saved_cards/domain/usecases/delete_saved_card.dart';
import '../../features/saved_cards/domain/usecases/get_saved_cards.dart';
import '../../features/saved_cards/domain/usecases/get_saved_cards_wallet_quota.dart';
import '../../features/saved_cards/domain/usecases/save_saved_card.dart';
import '../../features/saved_cards/domain/usecases/upgrade_wallet_plan.dart';
import '../../features/subscriptions/data/repositories/subscription_repository_impl.dart';
import '../../features/subscriptions/domain/usecases/configure_subscriptions.dart';
import '../../features/subscriptions/domain/usecases/identify_subscription_user.dart';
import '../../features/subscriptions/domain/usecases/logout_subscription_user.dart';
import '../../features/subscriptions/domain/usecases/restore_wallet_purchases.dart';
import '../../features/ads/data/repositories/interstitial_ad_repository_impl.dart';
import '../../features/ads/data/datasources/post_add_card_ad_counter_local_datasource.dart';
import '../../features/ads/domain/usecases/initialize_mobile_ads.dart';
import '../../features/ads/domain/usecases/show_post_add_card_monetization.dart';
import '../../features/settings/data/repositories/app_review_repository_impl.dart';
import '../../features/settings/data/datasources/theme_local_datasource.dart';
import '../../features/settings/data/repositories/theme_repository_impl.dart';
import '../../features/settings/domain/entities/theme_preference.dart';
import '../../features/settings/domain/usecases/get_theme_preference.dart';
import '../../features/settings/domain/usecases/request_app_review.dart';
import '../../features/settings/domain/usecases/set_theme_preference.dart';
import '../../features/support/data/datasources/support_remote_datasource.dart';
import '../../features/support/data/repositories/support_repository_impl.dart';
import '../../features/support/domain/usecases/submit_support_request.dart';
import '../auth/auth_token_coordinator.dart';
import '../auth/auth_token_provider.dart';
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
    final authTokenProvider = AuthTokenProvider(authLocal);
    AuthTokenCoordinator.install(
      AuthTokenCoordinator(
        local: authLocal,
        onSessionCleared: authLocal.clearSession,
      ),
    );

    final subscriptionRepo = SubscriptionRepositoryImpl();
    final configureSubscriptions = ConfigureSubscriptions(subscriptionRepo);
    await configureSubscriptions();
    final identifySubscriptionUser = IdentifySubscriptionUser(subscriptionRepo);
    final logoutSubscriptionUser = LogoutSubscriptionUser(subscriptionRepo);

    final interstitialAdRepo = InterstitialAdRepositoryImpl();
    await InitializeMobileAds(interstitialAdRepo)();
    final postAddCardAdCounter = PostAddCardAdCounterLocalDataSource(prefs);
    final showPostAddCardMonetization = ShowPostAddCardMonetization(
      interstitialAdRepo,
      subscriptionRepo,
      postAddCardAdCounter,
      authLocal,
    );

    final onboardingLocal = OnboardingLocalDataSourceImpl(prefs, authLocal);
    final onboardingRepo = OnboardingRepositoryImpl(onboardingLocal);
    final syncOnboardingFromServer = SyncOnboardingFromServer(onboardingRepo);

    final savedCardLocal = SavedCardLocalDataSourceImpl(prefs, authLocal);
    final savedCardRepo = SavedCardRepositoryImpl(
      local: savedCardLocal,
      remote: SavedCardRemoteDataSourceImpl(),
      authTokens: authTokenProvider,
    );
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
      onLogout: () async {
        final session = await authLocal.getSession();
        final userId = session?.userId;
        if (userId != null && userId.isNotEmpty) {
          await postAddCardAdCounter.clearForUser(userId);
        }
        await logoutSubscriptionUser();
        await clearUserScopedLocalData();
      },
    );
    final businessCards = _initBusinessCards(authTokenProvider);
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
    final initialThemePreference = await theme.getThemePreference();
    final appReview = _initAppReview();
    final support = _initSupport(authTokenProvider);
    final profile = _initProfile(authTokenProvider);

    final eventGroups = _initEventGroups(
      local: eventGroupLocal,
      authTokens: authTokenProvider,
    );
    final savedCards = _initSavedCards(
      savedCardRepo: savedCardRepo,
      subscriptionRepo: subscriptionRepo,
    );
    final restoreWalletPurchases = RestoreWalletPurchases(
      subscriptionRepo,
      savedCardRepo,
    );

    final session = await authLocal.getSession();
    if (session != null && session.userId.isNotEmpty) {
      await identifySubscriptionUser(session.userId);
    }

    return AppInitResult(
      restoreAuthSession: auth.restoreAuthSession,
      getAuthSession: auth.getAuthSession,
      identifySubscriptionUser: identifySubscriptionUser,
      loginWithEmail: auth.loginWithEmail,
      loginWithPhone: auth.loginWithPhone,
      loginWithLinkedIn: auth.loginWithLinkedIn,
      registerUser: auth.registerUser,
      forgotPassword: auth.forgotPassword,
      resetPassword: auth.resetPassword,
      getCurrentUser: auth.getCurrentUser,
      getLastLoginCredentials: auth.getLastLoginCredentials,
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
      initialThemePreference: initialThemePreference,
      submitSupportRequest: support.submitSupportRequest,
      requestAppReview: appReview.requestAppReview,
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
      restoreWalletPurchases: restoreWalletPurchases,
      linkSavedCardsToEventGroup: savedCards.linkSavedCardsToEventGroup,
      getProfileStats: profile.getProfileStats,
      showPostAddCardMonetization: showPostAddCardMonetization,
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
    required SubscriptionRepositoryImpl subscriptionRepo,
  }) {
    final getQuota = GetSavedCardsWalletQuota(savedCardRepo);
    final saveSavedCard = SaveSavedCard(savedCardRepo);
    return (
      getSavedCards: GetSavedCards(savedCardRepo),
      saveSavedCard: saveSavedCard,
      getSavedCardsWalletQuota: getQuota,
      addSavedCard: AddSavedCard(savedCardRepo),
      deleteSavedCard: DeleteSavedCard(savedCardRepo),
      upgradeWalletPlan: UpgradeWalletPlan(subscriptionRepo, savedCardRepo),
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
    required AuthTokenProvider authTokens,
  }) {
    final repo = EventGroupRepositoryImpl(
      local: local,
      remote: EventGroupRemoteDataSourceImpl(),
      authTokens: authTokens,
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
    LoginWithLinkedIn loginWithLinkedIn,
    RegisterUser registerUser,
    ForgotPassword forgotPassword,
    ResetPassword resetPassword,
    GetCurrentUser getCurrentUser,
    GetLastLoginCredentials getLastLoginCredentials,
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
      loginWithLinkedIn: LoginWithLinkedIn(repo),
      registerUser: RegisterUser(repo),
      forgotPassword: ForgotPassword(repo),
      resetPassword: ResetPassword(repo),
      getCurrentUser: GetCurrentUser(repo),
      getLastLoginCredentials: GetLastLoginCredentials(repo),
      logout: Logout(repo),
      uploadProfilePhoto: UploadProfilePhoto(repo),
      completeOnboardingRemote: CompleteOnboardingRemote(repo),
    );
  }

  static ({
    SaveBusinessCard saveBusinessCard,
    GetBusinessCards getBusinessCards,
    UpsertBusinessCard upsertBusinessCard,
  }) _initBusinessCards(AuthTokenProvider authTokens) {
    final remote = BusinessCardRemoteDataSourceImpl();
    final repo = BusinessCardRepositoryImpl(
      remote: remote,
      authTokens: authTokens,
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

  static ({RequestAppReview requestAppReview}) _initAppReview() {
    final repo = AppReviewRepositoryImpl();
    return (requestAppReview: RequestAppReview(repo));
  }

  static ({SubmitSupportRequest submitSupportRequest}) _initSupport(
    AuthTokenProvider authTokens,
  ) {
    final repo = SupportRepositoryImpl(
      remote: SupportRemoteDataSourceImpl(),
      authTokens: authTokens,
    );
    return (
      submitSupportRequest: SubmitSupportRequest(repo),
    );
  }

  static ({GetProfileStats getProfileStats}) _initProfile(
    AuthTokenProvider authTokens,
  ) {
    final repo = ProfileRepositoryImpl(
      remote: ProfileRemoteDataSourceImpl(),
      authTokens: authTokens,
    );
    return (
      getProfileStats: GetProfileStats(repo),
    );
  }
}

/// [AppInit.init] sonucu; [App] ve gerekirse diğer yerler tarafından kullanılır.
class AppInitResult {
  const AppInitResult({
    required this.restoreAuthSession,
    required this.getAuthSession,
    required this.identifySubscriptionUser,
    required this.loginWithEmail,
    required this.loginWithPhone,
    required this.loginWithLinkedIn,
    required this.registerUser,
    required this.forgotPassword,
    required this.resetPassword,
    required this.getCurrentUser,
    required this.getLastLoginCredentials,
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
    required this.initialThemePreference,
    required this.submitSupportRequest,
    required this.requestAppReview,
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
    required this.restoreWalletPurchases,
    required this.linkSavedCardsToEventGroup,
    required this.getProfileStats,
    required this.showPostAddCardMonetization,
  });

  final RestoreAuthSession restoreAuthSession;
  final GetAuthSession getAuthSession;
  final IdentifySubscriptionUser identifySubscriptionUser;
  final LoginWithEmail loginWithEmail;
  final LoginWithPhone loginWithPhone;
  final LoginWithLinkedIn loginWithLinkedIn;
  final RegisterUser registerUser;
  final ForgotPassword forgotPassword;
  final ResetPassword resetPassword;
  final GetCurrentUser getCurrentUser;
  final GetLastLoginCredentials getLastLoginCredentials;
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
  final ThemePreference initialThemePreference;
  final SubmitSupportRequest submitSupportRequest;
  final RequestAppReview requestAppReview;
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
  final RestoreWalletPurchases restoreWalletPurchases;
  final LinkSavedCardsToEventGroup linkSavedCardsToEventGroup;
  final GetProfileStats getProfileStats;
  final ShowPostAddCardMonetization showPostAddCardMonetization;
}
