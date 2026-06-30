import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

import 'app.dart';
import 'core/init/app_init.dart';
import 'core/network/interceptors/chuck_interceptor_service.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

void main() {
  runZonedGuarded(_bootstrap, (error, stackTrace) {
    debugPrint('[main] Uncaught zone error: $error');
    debugPrintStack(stackTrace: stackTrace);
  });
}

Future<void> _bootstrap() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    debugPrint('[main] FlutterError: ${details.exception}');
  };

  ChuckInterceptorService.instance.ensureInitialized(
    navigatorKey: rootNavigatorKey,
  );

  try {
    final result = await AppInit.init();
    _runApp(result);
  } catch (error, stackTrace) {
    debugPrint('[main] AppInit failed: $error');
    debugPrintStack(stackTrace: stackTrace);
  } finally {
    FlutterNativeSplash.remove();
  }
}

void _runApp(AppInitResult result) {
  runApp(App(
    rootNavigatorKey: rootNavigatorKey,
    restoreAuthSession: result.restoreAuthSession,
    getAuthSession: result.getAuthSession,
    identifySubscriptionUser: result.identifySubscriptionUser,
    loginWithEmail: result.loginWithEmail,
    loginWithPhone: result.loginWithPhone,
    loginWithLinkedIn: result.loginWithLinkedIn,
    registerUser: result.registerUser,
    getLastLoginCredentials: result.getLastLoginCredentials,
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
    initialThemePreference: result.initialThemePreference,
    getLocalePreference: result.getLocalePreference,
    setLocalePreference: result.setLocalePreference,
    initialLocalePreference: result.initialLocalePreference,
    submitSupportRequest: result.submitSupportRequest,
    requestAppReview: result.requestAppReview,
    getEventGroups: result.getEventGroups,
    createEventGroup: result.createEventGroup,
    updateEventGroup: result.updateEventGroup,
    inviteEventGroupCardsByCardId: result.inviteEventGroupCardsByCardId,
    deleteEventGroup: result.deleteEventGroup,
    linkEventGroupCards: result.linkEventGroupCards,
    linkSavedCardsToEventGroup: result.linkSavedCardsToEventGroup,
    getSavedCards: result.getSavedCards,
    saveSavedCard: result.saveSavedCard,
    getSavedCardsWalletQuota: result.getSavedCardsWalletQuota,
    addSavedCard: result.addSavedCard,
    deleteSavedCard: result.deleteSavedCard,
    trackSavedCardContactClick: result.trackSavedCardContactClick,
    upgradeWalletPlan: result.upgradeWalletPlan,
    restoreWalletPurchases: result.restoreWalletPurchases,
    getProfileStats: result.getProfileStats,
    getPlanEntitlements: result.getPlanEntitlements,
    getNetworkGraph: result.getNetworkGraph,
    getNetworkGraphPath: result.getNetworkGraphPath,
    showPostAddCardMonetization: result.showPostAddCardMonetization,
  ));
}
