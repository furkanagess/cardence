import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/l10n/l10n_extensions.dart';
import '../cubit/saved_cards_cubit.dart';
import '../cubit/saved_cards_state.dart';
import '../wallet_paywall_flow.dart';

/// Cüzdan kart daveti sayfası yan etkileri.
mixin WalletCardInvitationsPageEffectsMixin<T extends StatefulWidget> on State<T> {
  void handleWalletInvitationEffect(SavedCardsState state) {
    switch (state.effectType) {
      case SavedCardsEffectType.invitationAccepted:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.walletCardInvitationAccepted)),
        );
        context.read<SavedCardsCubit>().clearEffect();
      case SavedCardsEffectType.invitationRejected:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.walletCardInvitationRejected)),
        );
        context.read<SavedCardsCubit>().clearEffect();
      case SavedCardsEffectType.invitationQuotaFull:
        final cubit = context.read<SavedCardsCubit>();
        cubit.clearEffect();
        WalletPaywallFlow.show(context, cubit: cubit);
      default:
        break;
    }
  }
}
