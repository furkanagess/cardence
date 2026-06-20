import 'package:flutter/material.dart';

import 'cubit/saved_cards_cubit.dart';

/// RevenueCat paywall sunumu ve kota yenileme akışı.
class WalletPaywallFlow {
  WalletPaywallFlow._();

  static Future<void> show(
    BuildContext context, {
    required SavedCardsCubit cubit,
  }) async {
    await cubit.upgradeWallet();
  }
}
