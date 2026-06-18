import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

import 'app.dart';
import 'core/init/app_init.dart';
import 'core/network/interceptors/chuck_interceptor_service.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

void main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  ChuckInterceptorService.instance.ensureInitialized(
    navigatorKey: rootNavigatorKey,
  );

  final result = await AppInit.init();
  FlutterNativeSplash.remove();

  runApp(App(
    rootNavigatorKey: rootNavigatorKey,
    restoreAuthSession: result.restoreAuthSession,
    loginWithEmail: result.loginWithEmail,
    loginWithPhone: result.loginWithPhone,
    registerUser: result.registerUser,
    forgotPassword: result.forgotPassword,
    resetPassword: result.resetPassword,
    getCurrentUser: result.getCurrentUser,
    logout: result.logout,
    uploadProfilePhoto: result.uploadProfilePhoto,
    getOnboardingCompleted: result.getOnboardingCompleted,
    completeOnboarding: result.completeOnboarding,
    syncOnboardingFromServer: result.syncOnboardingFromServer,
    persistOnboardingCard: result.persistOnboardingCard,
    saveBusinessCard: result.saveBusinessCard,
    getOnboardingDraftCard: result.getOnboardingDraftCard,
    getOnboardingDraftCards: result.getOnboardingDraftCards,
    resolveOnboardingInitialDraft: result.resolveOnboardingInitialDraft,
    getThemePreference: result.getThemePreference,
    setThemePreference: result.setThemePreference,
    submitSupportRequest: result.submitSupportRequest,
    getEventGroups: result.getEventGroups,
    createEventGroup: result.createEventGroup,
    deleteEventGroup: result.deleteEventGroup,
    linkEventGroupCards: result.linkEventGroupCards,
    linkSavedCardsToEventGroup: result.linkSavedCardsToEventGroup,
    getSavedCards: result.getSavedCards,
    saveSavedCard: result.saveSavedCard,
    getSavedCardsWalletQuota: result.getSavedCardsWalletQuota,
    addSavedCard: result.addSavedCard,
    deleteSavedCard: result.deleteSavedCard,
    upgradeWalletPlan: result.upgradeWalletPlan,
    getProfileStats: result.getProfileStats,
  ));
}
