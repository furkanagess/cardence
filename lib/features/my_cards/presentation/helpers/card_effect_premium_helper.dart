import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/domain/card_visual_effect.dart';
import '../../../../core/l10n/l10n_extensions.dart';
import '../../../plans/presentation/cubit/plan_cubit.dart';
import '../../../plans/presentation/cubit/plan_state.dart';
import '../../../saved_cards/presentation/cubit/saved_cards_cubit.dart';
import '../../../saved_cards/presentation/wallet_paywall_flow.dart';
import '../../../onboarding/domain/entities/onboarding_card_draft.dart';

/// Kart efektleri için Pro plan erişim kontrolü.
class CardEffectPremiumHelper {
  CardEffectPremiumHelper._();

  static bool readIsPremium(BuildContext context) {
    try {
      final state = context.read<PlanCubit>().state;
      return state.entitlements?.isPremiumOrHigher ?? false;
    } catch (_) {
      return false;
    }
  }

  static Future<void> _refreshPlanIfAvailable(BuildContext context) async {
    try {
      await context.read<PlanCubit>().refresh();
    } catch (_) {}
  }

  static Future<bool> requestPremiumAccess(
    BuildContext context, {
    Future<bool> Function()? onRequestPremium,
  }) async {
    if (readIsPremium(context)) return true;

    if (onRequestPremium != null) {
      final upgraded = await onRequestPremium();
      if (!context.mounted) return false;
      if (upgraded) {
        await _refreshPlanIfAvailable(context);
        return readIsPremium(context);
      }
    }

    try {
      final cubit = context.read<SavedCardsCubit>();
      await WalletPaywallFlow.show(context, cubit: cubit);
      if (!context.mounted) return false;
      return readIsPremium(context);
    } catch (_) {
      return false;
    }
  }

  static bool blocksPremiumEffectSelection({
    required CardVisualEffect effect,
    required bool isPremium,
  }) =>
      !isPremium && effect.requiresPremium;

  /// Sunucuya kayıt öncesi: Pro yoksa paywall gösterir; kabul edilmezse efekt sıfırlanır.
  static Future<OnboardingCardDraft?> resolveDraftForPersist(
    BuildContext context,
    OnboardingCardDraft draft, {
    Future<bool> Function()? onRequestPremium,
  }) async {
    if (!draft.cardEffect.requiresPremium) return draft;
    if (readIsPremium(context)) return draft;

    final unlocked = await requestPremiumAccess(
      context,
      onRequestPremium: onRequestPremium,
    );
    if (!context.mounted) return null;
    if (unlocked) return draft;

    return draft.copyWith(cardEffect: CardVisualEffect.none);
  }

  static void showEffectStrippedNotice(BuildContext context) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;
    messenger.showSnackBar(
      SnackBar(content: Text(context.l10n.efektKayitProGerekli)),
    );
  }

  static Widget build({
    required Widget Function(BuildContext context, bool isPremium) builder,
  }) {
    return _CardEffectPremiumBuilder(builder: builder);
  }
}

class _CardEffectPremiumBuilder extends StatelessWidget {
  const _CardEffectPremiumBuilder({required this.builder});

  final Widget Function(BuildContext context, bool isPremium) builder;

  @override
  Widget build(BuildContext context) {
    PlanCubit? planCubit;
    try {
      planCubit = context.read<PlanCubit>();
    } catch (_) {
      return builder(context, false);
    }

    return BlocBuilder<PlanCubit, PlanState>(
      bloc: planCubit,
      buildWhen: (previous, current) =>
          previous.entitlements?.tier != current.entitlements?.tier,
      builder: (context, state) {
        final isPremium = state.entitlements?.isPremiumOrHigher ?? false;
        return builder(context, isPremium);
      },
    );
  }
}

/// Kart kaydı öncesi efekt Pro kontrolü.
Future<OnboardingCardDraft?> prepareCardDraftForPersist(
  BuildContext context,
  OnboardingCardDraft draft, {
  Future<bool> Function()? onRequestPremium,
}) async {
  final originalEffect = draft.cardEffect;
  final resolved = await CardEffectPremiumHelper.resolveDraftForPersist(
    context,
    draft,
    onRequestPremium: onRequestPremium,
  );
  if (!context.mounted || resolved == null) return null;
  if (resolved.cardEffect != originalEffect) {
    CardEffectPremiumHelper.showEffectStrippedNotice(context);
  }
  return resolved;
}
