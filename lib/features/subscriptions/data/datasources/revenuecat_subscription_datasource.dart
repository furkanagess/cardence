import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';

import '../../../../core/config/revenuecat_config.dart';
import '../../domain/entities/wallet_paywall_result.dart';

class RevenueCatSubscriptionDataSource {
  Future<void> configure() async {
    await Purchases.setLogLevel(kDebugMode ? LogLevel.debug : LogLevel.info);
    await Purchases.configure(
      PurchasesConfiguration(RevenueCatConfig.apiKey),
    );
  }

  Future<void> identifyUser(String userId) async {
    if (userId.isEmpty) return;
    await Purchases.logIn(userId);
  }

  Future<void> logoutUser() async {
    try {
      await Purchases.logOut();
    } catch (_) {
      // Zaten anonim kullanıcı olabilir.
    }
  }

  Future<bool> purchaseWalletPremium() async {
    final result = await presentWalletPaywall();
    return result == WalletPaywallResult.purchased ||
        result == WalletPaywallResult.restored ||
        (result == WalletPaywallResult.notPresented &&
            await hasPremiumWalletEntitlement());
  }

  Future<WalletPaywallResult> presentWalletPaywall() async {
    try {
      final result = await RevenueCatUI.presentPaywallIfNeeded(
        RevenueCatConfig.premiumEntitlementId,
        displayCloseButton: true,
      );
      return _mapPaywallResult(result);
    } catch (_) {
      return WalletPaywallResult.error;
    }
  }

  WalletPaywallResult _mapPaywallResult(PaywallResult result) {
    switch (result) {
      case PaywallResult.notPresented:
        return WalletPaywallResult.notPresented;
      case PaywallResult.cancelled:
        return WalletPaywallResult.cancelled;
      case PaywallResult.error:
        return WalletPaywallResult.error;
      case PaywallResult.purchased:
        return WalletPaywallResult.purchased;
      case PaywallResult.restored:
        return WalletPaywallResult.restored;
    }
  }

  Future<bool> restorePurchases() async {
    final customerInfo = await Purchases.restorePurchases();
    return _hasPremiumEntitlement(customerInfo);
  }

  Future<bool> hasPremiumWalletEntitlement() async {
    final customerInfo = await Purchases.getCustomerInfo();
    return _hasPremiumEntitlement(customerInfo);
  }

  bool _hasPremiumEntitlement(CustomerInfo customerInfo) {
    return customerInfo.entitlements.active
        .containsKey(RevenueCatConfig.premiumEntitlementId);
  }
}
