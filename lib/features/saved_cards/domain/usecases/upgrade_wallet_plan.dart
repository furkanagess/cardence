import '../../../auth/domain/usecases/refresh_current_user.dart';
import '../../../../core/user_data/sync_user_profile_cards.dart';
import '../../../subscriptions/domain/entities/wallet_paywall_result.dart';
import '../../../subscriptions/domain/repositories/subscription_repository.dart';
import '../../../subscriptions/domain/usecases/finalize_premium_wallet_activation.dart';
import '../../../plans/domain/entities/plan_tier.dart';
import '../../../plans/domain/usecases/get_plan_entitlements.dart';

/// RevenueCat paywall üzerinden satın alma ve sunucu kotası senkronizasyonu.
class UpgradeWalletPlan {
  const UpgradeWalletPlan(
    this._subscriptionRepository,
    this._getPlanEntitlements,
    this._finalizePremiumWalletActivation,
    this._refreshCurrentUser,
    this._syncUserProfileCards,
  );

  final SubscriptionRepository _subscriptionRepository;
  final GetPlanEntitlements _getPlanEntitlements;
  final FinalizePremiumWalletActivation _finalizePremiumWalletActivation;
  final RefreshCurrentUser _refreshCurrentUser;
  final SyncUserProfileCards _syncUserProfileCards;

  Future<bool> call({
    bool onlyIfNeeded = false,
    bool? useDarkAppearance,
  }) async {
    final result = await _subscriptionRepository.presentWalletPaywall(
      onlyIfNeeded: onlyIfNeeded,
      useDarkAppearance: useDarkAppearance,
    );

    switch (result) {
      case WalletPaywallResult.cancelled:
      case WalletPaywallResult.error:
        return false;
      case WalletPaywallResult.notPresented:
        if (!onlyIfNeeded &&
            await _subscriptionRepository.hasPremiumWalletEntitlement()) {
          await _completePremiumActivation();
          return true;
        }
        return false;
      case WalletPaywallResult.purchased:
      case WalletPaywallResult.restored:
        await _completePremiumActivation();
        return true;
    }
  }

  Future<void> _completePremiumActivation() async {
    await _waitForRevenueCatEntitlement();
    await _finalizeWithRetry();
    await _waitForBackendPremiumEntitlement();
    await _refreshProfileAfterPurchase();
  }

  Future<void> _finalizeWithRetry() async {
    for (var attempt = 0; attempt < 3; attempt++) {
      try {
        await _finalizePremiumWalletActivation();
        return;
      } catch (_) {
        if (attempt < 2) {
          await Future<void>.delayed(const Duration(seconds: 1));
        }
      }
    }
  }

  Future<void> _refreshProfileAfterPurchase() async {
    for (var attempt = 0; attempt < 3; attempt++) {
      try {
        final profile = await _refreshCurrentUser();
        if (profile.isOwnerPremium || profile.isPremium) {
          await _syncUserProfileCards(profile);
          return;
        }
      } catch (_) {
        // Sonraki denemeye geç.
      }

      if (attempt < 2) {
        await Future<void>.delayed(const Duration(seconds: 1));
      }
    }

    try {
      final profile = await _refreshCurrentUser();
      await _syncUserProfileCards(profile);
    } catch (_) {
      // Başarı handler ikinci kez dener.
    }
  }

  Future<void> _waitForRevenueCatEntitlement() async {
    for (var attempt = 0; attempt < 10; attempt++) {
      if (await _subscriptionRepository.hasPremiumWalletEntitlement()) {
        return;
      }

      if (attempt < 9) {
        await Future<void>.delayed(const Duration(milliseconds: 500));
      }
    }
  }

  Future<bool> _waitForBackendPremiumEntitlement() async {
    for (var attempt = 0; attempt < 5; attempt++) {
      final entitlements = await _getPlanEntitlements();
      if (entitlements.tier == PlanTier.premium ||
          entitlements.tier == PlanTier.business ||
          entitlements.tier == PlanTier.enterprise) {
        return true;
      }

      if (attempt < 4) {
        await Future<void>.delayed(const Duration(seconds: 1));
      }
    }

    return false;
  }
}
