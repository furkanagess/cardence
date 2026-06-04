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
    getOnboardingCompleted: result.getOnboardingCompleted,
    completeOnboarding: result.completeOnboarding,
    saveOnboardingDraftCard: result.saveOnboardingDraftCard,
    getOnboardingDraftCard: result.getOnboardingDraftCard,
    getOnboardingDraftCards: result.getOnboardingDraftCards,
    getThemePreference: result.getThemePreference,
    setThemePreference: result.setThemePreference,
    getEventGroups: result.getEventGroups,
    saveEventGroups: result.saveEventGroups,
    getSavedCards: result.getSavedCards,
    saveSavedCard: result.saveSavedCard,
    getSavedCardsWalletQuota: result.getSavedCardsWalletQuota,
    addSavedCard: result.addSavedCard,
    upgradeWalletPlan: result.upgradeWalletPlan,
  ));
}
