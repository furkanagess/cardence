import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/user_data/sync_user_profile_cards.dart';
import '../../../../core/widgets/molecules/purchase_success_dialog.dart';
import '../../../auth/domain/usecases/refresh_current_user.dart';
import '../../../plans/presentation/cubit/plan_cubit.dart';
import '../../../saved_cards/presentation/cubit/saved_cards_cubit.dart';

/// Başarılı premium satın alma / geri yükleme sonrası Me yenileme ve dialog.
class PremiumPurchaseSuccessHandler {
  const PremiumPurchaseSuccessHandler({
    required RefreshCurrentUser refreshCurrentUser,
    required SyncUserProfileCards syncUserProfileCards,
  })  : _refreshCurrentUser = refreshCurrentUser,
        _syncUserProfileCards = syncUserProfileCards;

  final RefreshCurrentUser _refreshCurrentUser;
  final SyncUserProfileCards _syncUserProfileCards;

  Future<void> showSuccess(BuildContext context) async {
    final profile = await _refreshCurrentUser();
    await _syncUserProfileCards(profile);
    if (!context.mounted) return;

    try {
      await context.read<PlanCubit>().refresh();
    } catch (_) {
      // Paywall shell dışından da çağrılabilir.
    }

    if (!context.mounted) return;

    try {
      await context.read<SavedCardsCubit>().refreshAll();
    } catch (_) {
      // Kayıtlı kartlar sekmesi dışından da çağrılabilir.
    }

    if (!context.mounted) return;
    await PurchaseSuccessDialog.show(context);
  }
}
