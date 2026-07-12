import 'package:flutter/material.dart';

import '../../subscriptions/presentation/helpers/premium_purchase_success_handler.dart';
import '../../subscriptions/presentation/widgets/premium_purchase_scope.dart';
import 'cubit/saved_cards_cubit.dart';

/// RevenueCat paywall sunumu ve kota yenileme akışı.
class WalletPaywallFlow {
  WalletPaywallFlow._();

  static Future<void> show(
    BuildContext context, {
    required SavedCardsCubit cubit,
    PremiumPurchaseSuccessHandler? successHandler,
    bool onlyIfNeeded = false,
  }) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final success = await cubit.upgradeWallet(
      onlyIfNeeded: onlyIfNeeded,
      useDarkAppearance: isDark,
    );
    if (!context.mounted || !success) return;

    final handler = successHandler ?? PremiumPurchaseScope.maybeOf(context);
    if (handler == null) return;

    await handler.showSuccess(context);
    if (!context.mounted) return;
    await cubit.refreshAll();
  }
}
