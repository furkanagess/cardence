import 'package:flutter/foundation.dart';

import '../../../auth/domain/usecases/get_auth_session.dart';
import '../../../auth/domain/usecases/refresh_current_user.dart';
import '../../../../core/user_data/sync_user_profile_cards.dart';
import '../../../subscriptions/domain/entities/wallet_paywall_result.dart';
import '../../../subscriptions/domain/repositories/subscription_repository.dart';
import '../../../subscriptions/domain/usecases/finalize_premium_wallet_activation.dart';
import '../../../plans/domain/usecases/get_plan_entitlements.dart';

/// RevenueCat paywall üzerinden satın alma ve sunucu kotası senkronizasyonu.
class UpgradeWalletPlan {
  const UpgradeWalletPlan(
    this._subscriptionRepository,
    this._getPlanEntitlements,
    this._finalizePremiumWalletActivation,
    this._refreshCurrentUser,
    this._syncUserProfileCards,
    this._getAuthSession,
  );

  final SubscriptionRepository _subscriptionRepository;
  final GetPlanEntitlements _getPlanEntitlements;
  final FinalizePremiumWalletActivation _finalizePremiumWalletActivation;
  final RefreshCurrentUser _refreshCurrentUser;
  final SyncUserProfileCards _syncUserProfileCards;
  final GetAuthSession _getAuthSession;

  Future<bool> call({
    bool onlyIfNeeded = false,
    bool? useDarkAppearance,
    String? preferredLocale,
  }) async {
    await _tryEnsureRevenueCatIdentity();

    final result = await _subscriptionRepository.presentWalletPaywall(
      onlyIfNeeded: onlyIfNeeded,
      useDarkAppearance: useDarkAppearance,
      preferredLocale: preferredLocale,
    );

    switch (result) {
      case WalletPaywallResult.cancelled:
      case WalletPaywallResult.error:
        return false;
      case WalletPaywallResult.notPresented:
        if (!onlyIfNeeded &&
            await _subscriptionRepository.hasPremiumWalletEntitlement()) {
          await _syncAfterPurchase();
          return true;
        }
        return false;
      case WalletPaywallResult.purchased:
      case WalletPaywallResult.restored:
        await _syncAfterPurchase();
        return true;
    }
  }

  Future<void> _tryEnsureRevenueCatIdentity() async {
    try {
      final session = await _getAuthSession();
      final userId = session?.userId.trim() ?? '';
      if (userId.isEmpty) return;
      await _subscriptionRepository.identifyUser(userId);
    } catch (error, stackTrace) {
      debugPrint('[UpgradeWalletPlan] RC identify failed: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  /// Önce `POST /UpgradeWalletPlan` (DB premium), sonra `/Me` yenile.
  /// RC identify hatası sunucu yazımını engellemez.
  Future<void> _syncAfterPurchase() async {
    for (var attempt = 0; attempt < 5; attempt++) {
      try {
        final quota = await _finalizePremiumWalletActivation(
          requirePremium: true,
        );
        debugPrint(
          '[UpgradeWalletPlan] UpgradeWalletPlan ok '
          '(attempt=${attempt + 1}, tier=${quota.tier.name})',
        );

        final profile = await _refreshCurrentUser();
        await _syncUserProfileCards(profile);
        debugPrint(
          '[UpgradeWalletPlan] /Me premium=${profile.isPremium} '
          'isOwnerPremium=${profile.isOwnerPremium}',
        );
        if (profile.isOwnerPremium || profile.isPremium) {
          await _refreshPlanEntitlements();
          return;
        }
      } catch (error, stackTrace) {
        debugPrint(
          '[UpgradeWalletPlan] sync attempt ${attempt + 1} failed: $error',
        );
        debugPrintStack(stackTrace: stackTrace);
      }

      if (attempt < 4) {
        await Future<void>.delayed(Duration(milliseconds: 400 * (attempt + 1)));
      }
    }

    try {
      await _finalizePremiumWalletActivation(requirePremium: false);
    } catch (error) {
      debugPrint('[UpgradeWalletPlan] final UpgradeWalletPlan failed: $error');
    }
    try {
      final profile = await _refreshCurrentUser();
      await _syncUserProfileCards(profile);
      debugPrint(
        '[UpgradeWalletPlan] final /Me premium=${profile.isPremium} '
        'isOwnerPremium=${profile.isOwnerPremium}',
      );
    } catch (error) {
      debugPrint('[UpgradeWalletPlan] final /Me failed: $error');
    }
    await _refreshPlanEntitlements();
  }

  Future<void> _refreshPlanEntitlements() async {
    try {
      await _getPlanEntitlements();
    } catch (_) {}
  }
}
