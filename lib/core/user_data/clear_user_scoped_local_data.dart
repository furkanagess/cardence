import 'package:shared_preferences/shared_preferences.dart';

import '../../features/auth/data/datasources/auth_local_datasource.dart';
import '../../features/event_groups/data/datasources/event_group_local_datasource.dart';
import '../../features/onboarding/data/datasources/onboarding_local_datasource.dart';
import '../../features/saved_cards/data/datasources/saved_card_local_datasource.dart';
import '../../features/saved_cards/data/datasources/wallet_entitlement_local_datasource.dart';

/// Oturum kapanırken kullanıcıya özel tüm yerel verileri temizler.
class ClearUserScopedLocalData {
  ClearUserScopedLocalData({
    required AuthLocalDataSource authLocal,
    required SavedCardLocalDataSource savedCardLocal,
    required OnboardingLocalDataSource onboardingLocal,
    required SharedPreferences prefs,
  })  : _authLocal = authLocal,
        _savedCardLocal = savedCardLocal,
        _onboardingLocal = onboardingLocal,
        _prefs = prefs;

  final AuthLocalDataSource _authLocal;
  final SavedCardLocalDataSource _savedCardLocal;
  final OnboardingLocalDataSource _onboardingLocal;
  final SharedPreferences _prefs;

  Future<void> call() async {
    final session = await _authLocal.getSession();
    final userId = session?.userId;
    if (userId != null && userId.isNotEmpty) {
      await _savedCardLocal.clearForUser(userId);
      await _onboardingLocal.clearForUser(userId);
    }
    await _savedCardLocal.clearLegacyKeys();
    await _onboardingLocal.clearLegacyKeys();
    await _prefs.remove(eventGroupsStorageKey);
    await _prefs.remove(WalletEntitlementLocalDataSourceImpl.walletPlanTierStorageKey);
  }
}
