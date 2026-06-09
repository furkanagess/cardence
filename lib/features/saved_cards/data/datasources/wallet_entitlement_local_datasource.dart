import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/wallet_plan_tier.dart';

abstract class WalletEntitlementLocalDataSource {
  Future<WalletPlanTier> getPlanTier();

  Future<void> setPlanTier(WalletPlanTier tier);

  Future<void> clear();
}

class WalletEntitlementLocalDataSourceImpl
    implements WalletEntitlementLocalDataSource {
  WalletEntitlementLocalDataSourceImpl(this._prefs);

  static const walletPlanTierStorageKey = 'wallet_plan_tier';

  final SharedPreferences _prefs;

  @override
  Future<WalletPlanTier> getPlanTier() async {
    final raw = _prefs.getString(walletPlanTierStorageKey);
    if (raw == WalletPlanTier.premium.name) {
      return WalletPlanTier.premium;
    }
    return WalletPlanTier.free;
  }

  @override
  Future<void> setPlanTier(WalletPlanTier tier) async {
    await _prefs.setString(walletPlanTierStorageKey, tier.name);
  }

  @override
  Future<void> clear() async {
    await _prefs.remove(walletPlanTierStorageKey);
  }
}
