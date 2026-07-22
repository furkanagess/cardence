import 'package:flutter/material.dart';

import '../../../core/l10n/locale_preference_material.dart';
import '../../subscriptions/presentation/helpers/premium_purchase_success_handler.dart';
import '../../subscriptions/presentation/widgets/premium_purchase_scope.dart';
import 'cubit/saved_cards_cubit.dart';

/// RevenueCat paywall sunumu ve kota yenileme akışı.
class WalletPaywallFlow {
  WalletPaywallFlow._();

  static Future<bool> show(
    BuildContext context, {
    required SavedCardsCubit cubit,
    PremiumPurchaseSuccessHandler? successHandler,
    bool onlyIfNeeded = false,
  }) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final preferredLocale = revenueCatPreferredLocaleFrom(
      Localizations.localeOf(context),
    );
    final purchased = await cubit.upgradeWallet(
      onlyIfNeeded: onlyIfNeeded,
      useDarkAppearance: isDark,
      preferredLocale: preferredLocale,
    );
    if (!context.mounted || !purchased) return false;

    // Paywall kapandı → /Me + Plan + cüzdan ekranı yenile.
    final handler = successHandler ?? PremiumPurchaseScope.maybeOf(context);
    if (handler != null) {
      await handler.showSuccess(context);
    } else {
      await cubit.refreshAll();
    }

    if (!context.mounted) return true;
    await WidgetsBinding.instance.endOfFrame;
    if (context.mounted) {
      await cubit.refreshAll();
    }
    return true;
  }
}
