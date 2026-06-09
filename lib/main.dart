import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

import 'app.dart';
import 'core/init/app_init.dart';

void main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  final result = await AppInit.init();
  FlutterNativeSplash.remove();

  runApp(App(
    restoreAuthSession: result.restoreAuthSession,
    loginWithEmail: result.loginWithEmail,
    loginWithPhone: result.loginWithPhone,
    registerUser: result.registerUser,
    forgotPassword: result.forgotPassword,
    resetPassword: result.resetPassword,
    getCurrentUser: result.getCurrentUser,
    logout: result.logout,
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
    getEventGroups: result.getEventGroups,
    saveEventGroups: result.saveEventGroups,
    getSavedCards: result.getSavedCards,
    saveSavedCard: result.saveSavedCard,
    getSavedCardsWalletQuota: result.getSavedCardsWalletQuota,
    addSavedCard: result.addSavedCard,
    deleteSavedCard: result.deleteSavedCard,
    upgradeWalletPlan: result.upgradeWalletPlan,
  ));
}
