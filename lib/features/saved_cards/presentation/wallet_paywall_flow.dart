import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/widgets/molecules/purchase_success_dialog.dart';
import '../../plans/presentation/cubit/plan_cubit.dart';
import 'cubit/saved_cards_cubit.dart';

/// RevenueCat paywall sunumu ve kota yenileme akışı.
class WalletPaywallFlow {
  WalletPaywallFlow._();

  static Future<void> show(
    BuildContext context, {
    required SavedCardsCubit cubit,
    bool onlyIfNeeded = false,
  }) async {
    final success = await cubit.upgradeWallet(onlyIfNeeded: onlyIfNeeded);
    if (!context.mounted || !success) return;
    await _refreshPlanIfAvailable(context);
    if (!context.mounted) return;
    await PurchaseSuccessDialog.show(context);
  }

  static Future<void> _refreshPlanIfAvailable(BuildContext context) async {
    try {
      await context.read<PlanCubit>().refresh();
    } catch (_) {
      // Some legacy flows can present the wallet paywall outside the shell tree.
    }
  }
}
