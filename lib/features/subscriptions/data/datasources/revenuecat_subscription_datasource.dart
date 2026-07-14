import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';

import '../../../../core/config/revenuecat_config.dart';
import '../../../../core/platform/paywall_appearance_override.dart';
import '../../domain/entities/wallet_paywall_result.dart';

class RevenueCatSubscriptionDataSource {
  Completer<void>? _configureCompleter;
  Future<void> Function()? _entitlementChangeHandler;
  bool _entitlementListenerRegistered = false;

  void registerEntitlementChangeHandler(Future<void> Function()? handler) {
    _entitlementChangeHandler = handler;
  }

  Future<void> configure() async {
    if (_configureCompleter != null) {
      return _configureCompleter!.future;
    }

    final completer = Completer<void>();
    _configureCompleter = completer;

    try {
      await Purchases.setLogLevel(kDebugMode ? LogLevel.debug : LogLevel.info);
      await Purchases.configure(
        PurchasesConfiguration(RevenueCatConfig.apiKey),
      );
      _registerEntitlementListener();
      completer.complete();
    } catch (error, stackTrace) {
      _configureCompleter = null;
      completer.completeError(error, stackTrace);
      rethrow;
    }
  }

  Future<void> _ensureConfigured() async {
    if (_configureCompleter == null) {
      await configure();
      return;
    }
    await _configureCompleter!.future;
  }

  void _registerEntitlementListener() {
    if (_entitlementListenerRegistered) return;
    _entitlementListenerRegistered = true;
    Purchases.addCustomerInfoUpdateListener((_) {
      final handler = _entitlementChangeHandler;
      if (handler == null) return;
      unawaited(handler());
    });
  }

  Future<void> identifyUser(String userId) async {
    if (userId.isEmpty) return;
    await _ensureConfigured();
    await Purchases.logIn(userId);
  }

  Future<void> logoutUser() async {
    try {
      await _ensureConfigured();
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

  Future<WalletPaywallResult> presentWalletPaywall({
    bool onlyIfNeeded = false,
    bool? useDarkAppearance,
    String? preferredLocale,
  }) async {
    try {
      await _ensureConfigured();
      await setPreferredLocale(preferredLocale);
      final offering = await _resolveWalletOffering();
      if (offering == null) {
        debugPrint('[RevenueCat] No offering resolved; paywall cannot open.');
        return WalletPaywallResult.error;
      }

      debugPrint(
        '[RevenueCat] Presenting paywall '
        '(paywall=${RevenueCatConfig.walletPaywallIdentifier}, '
        'offering=${offering.identifier}, onlyIfNeeded=$onlyIfNeeded, '
        'useDarkAppearance=$useDarkAppearance, '
        'preferredLocale=$preferredLocale)',
      );

      if (useDarkAppearance != null) {
        await PaywallAppearanceOverride.apply(isDark: useDarkAppearance);
      }

      try {
        final PaywallResult result;
        if (onlyIfNeeded) {
          result = await RevenueCatUI.presentPaywallIfNeeded(
            RevenueCatConfig.premiumEntitlementId,
            offering: offering,
            displayCloseButton: true,
            presentationConfiguration: PaywallPresentationConfiguration.fullScreen,
          );
        } else {
          result = await RevenueCatUI.presentPaywall(
            offering: offering,
            displayCloseButton: true,
            presentationConfiguration: PaywallPresentationConfiguration.fullScreen,
          );
        }

        debugPrint('[RevenueCat] Paywall result: $result');
        if (result == PaywallResult.purchased ||
            result == PaywallResult.restored) {
          await Purchases.invalidateCustomerInfoCache();
          await Purchases.getCustomerInfo();
        }
        return _mapPaywallResult(result);
      } finally {
        if (useDarkAppearance != null) {
          await PaywallAppearanceOverride.reset();
        }
      }
    } catch (error, stackTrace) {
      debugPrint('[RevenueCat] presentWalletPaywall failed: $error');
      debugPrintStack(stackTrace: stackTrace);
      return WalletPaywallResult.error;
    }
  }

  Future<void> setPreferredLocale(String? locale) async {
    await _ensureConfigured();
    try {
      await Purchases.overridePreferredUILocale(locale);
      debugPrint('[RevenueCat] preferredUILocale=$locale');
    } catch (error, stackTrace) {
      debugPrint('[RevenueCat] setPreferredLocale failed: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  Future<Offering?> _resolveWalletOffering() async {
    final paywallId = RevenueCatConfig.walletPaywallIdentifier;
    final placementId = RevenueCatConfig.walletPlacementIdentifier;
    final offeringId = RevenueCatConfig.walletOfferingIdentifier;

    if (placementId.isNotEmpty) {
      try {
        final placementOffering =
            await Purchases.getCurrentOfferingForPlacement(placementId);
        if (placementOffering != null) {
          final packageIds = placementOffering.availablePackages
              .map((package) => package.identifier)
              .join(', ');
          debugPrint(
            '[RevenueCat] Using placement "$placementId" '
            '(paywall=$paywallId, offering=${placementOffering.identifier}, '
            'packages: $packageIds).',
          );
          return placementOffering;
        }
        debugPrint(
          '[RevenueCat] Placement "$placementId" returned no offering.',
        );
      } catch (error) {
        debugPrint(
          '[RevenueCat] Placement "$placementId" failed: $error',
        );
      }
    }

    final offerings = await Purchases.getOfferings();

    final paywallOffering = offerings.getOffering(paywallId);
    if (paywallOffering != null) {
      final packageIds = paywallOffering.availablePackages
          .map((package) => package.identifier)
          .join(', ');
      debugPrint(
        '[RevenueCat] Using paywall offering "$paywallId" '
        '(packages: $packageIds).',
      );
      return paywallOffering;
    }

    final configuredOffering = offerings.getOffering(offeringId);
    if (configuredOffering != null) {
      final packageIds = configuredOffering.availablePackages
          .map((package) => package.identifier)
          .join(', ');
      debugPrint(
        '[RevenueCat] Using offering "$offeringId" '
        '(paywall=$paywallId, packages: $packageIds).',
      );
      return configuredOffering;
    }

    debugPrint(
      '[RevenueCat] Offering "$offeringId" and paywall "$paywallId" not found. '
      'Available: ${offerings.all.keys.join(', ')}',
    );

    if (offerings.current != null) {
      debugPrint(
        '[RevenueCat] Falling back to current offering '
        '"${offerings.current!.identifier}".',
      );
      return offerings.current;
    }

    return null;
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
    await _ensureConfigured();
    final customerInfo = await Purchases.restorePurchases();
    return _hasPremiumEntitlement(customerInfo);
  }

  Future<bool> hasPremiumWalletEntitlement() async {
    await _ensureConfigured();
    final customerInfo = await Purchases.getCustomerInfo();
    return _hasPremiumEntitlement(customerInfo);
  }

  bool _hasPremiumEntitlement(CustomerInfo customerInfo) {
    return customerInfo.entitlements.active
        .containsKey(RevenueCatConfig.premiumEntitlementId);
  }
}
