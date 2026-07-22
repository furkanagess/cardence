import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/user_data/sync_user_profile_cards.dart';
import '../../../../core/widgets/molecules/purchase_success_dialog.dart';
import '../../../auth/domain/entities/user_profile.dart';
import '../../../auth/domain/usecases/refresh_current_user.dart';
import '../../../plans/presentation/cubit/plan_cubit.dart';
import '../../../saved_cards/presentation/cubit/saved_cards_cubit.dart';

/// Başarılı premium satın alma sonrası Me yenileme + ekran rebuild.
class PremiumPurchaseSuccessHandler {
  const PremiumPurchaseSuccessHandler({
    required RefreshCurrentUser refreshCurrentUser,
    required SyncUserProfileCards syncUserProfileCards,
  })  : _refreshCurrentUser = refreshCurrentUser,
        _syncUserProfileCards = syncUserProfileCards;

  final RefreshCurrentUser _refreshCurrentUser;
  final SyncUserProfileCards _syncUserProfileCards;

  Future<void> showSuccess(BuildContext context) async {
    await refreshMeAndUi(context);
    if (!context.mounted) return;
    await PurchaseSuccessDialog.show(context);
  }

  /// Paywall kapandıktan sonra /Me + Plan + SavedCards yeniler.
  Future<UserProfile?> refreshMeAndUi(BuildContext context) async {
    final profile = await _refreshMe();
    if (profile != null) {
      await _syncUserProfileCards(profile);
    }
    if (!context.mounted) return profile;

    await _refreshPremiumUi(context);
    if (!context.mounted) return profile;

    await WidgetsBinding.instance.endOfFrame;
    return profile;
  }

  Future<UserProfile?> _refreshMe() async {
    UserProfile? lastProfile;
    for (var attempt = 0; attempt < 6; attempt++) {
      try {
        lastProfile = await _refreshCurrentUser();
        if (lastProfile.isOwnerPremium || lastProfile.isPremium) {
          return lastProfile;
        }
      } catch (_) {}
      if (attempt < 5) {
        await Future<void>.delayed(Duration(milliseconds: 300 * (attempt + 1)));
      }
    }
    return lastProfile;
  }

  Future<void> _refreshPremiumUi(BuildContext context) async {
    final futures = <Future<void>>[];

    try {
      futures.add(context.read<PlanCubit>().refresh());
    } catch (_) {}

    try {
      futures.add(context.read<SavedCardsCubit>().refreshAll());
    } catch (_) {}

    if (futures.isNotEmpty) {
      await Future.wait(futures);
    }
  }
}
