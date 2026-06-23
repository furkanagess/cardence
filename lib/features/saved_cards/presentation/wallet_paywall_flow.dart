import 'package:flutter/material.dart';

import '../../../../core/widgets/molecules/purchase_success_dialog.dart';
import 'cubit/saved_cards_cubit.dart';

/// RevenueCat paywall sunumu ve kota yenileme akışı.
class WalletPaywallFlow {
  WalletPaywallFlow._();

  static Future<void> show(
    BuildContext context, {
    required SavedCardsCubit cubit,
  }) async {
    final success = await cubit.upgradeWallet();
    if (!context.mounted || !success) return;
    await PurchaseSuccessDialog.show(context);
  }
}
