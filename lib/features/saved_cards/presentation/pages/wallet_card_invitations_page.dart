import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/l10n/l10n_extensions.dart';
import '../../../../core/widgets/atoms/cardence_app_bar.dart';
import '../../../../core/widgets/organisms/cardence_scaffold.dart';
import '../cubit/saved_cards_cubit.dart';
import '../cubit/saved_cards_state.dart';
import '../mixins/wallet_card_invitations_page_effects_mixin.dart';
import '../widgets/wallet_card_invitation_card.dart';

/// Kaydedilen kart davetleri: “sizi cüzdanına ekledi / siz de eklemek ister misiniz?”
class WalletCardInvitationsPage extends StatefulWidget {
  const WalletCardInvitationsPage({super.key});

  @override
  State<WalletCardInvitationsPage> createState() =>
      _WalletCardInvitationsPageState();
}

class _WalletCardInvitationsPageState extends State<WalletCardInvitationsPage>
    with WalletCardInvitationsPageEffectsMixin {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<SavedCardsCubit>().refreshAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return BlocListener<SavedCardsCubit, SavedCardsState>(
      listenWhen: (previous, current) =>
          previous.effectType != current.effectType,
      listener: (context, state) => handleWalletInvitationEffect(state),
      child: CardenceScaffold(
        appBar: CardenceAppBar(
          title: context.l10n.walletCardInvitationsPageTitle,
        ),
        body: BlocBuilder<SavedCardsCubit, SavedCardsState>(
          builder: (context, state) {
            final cubit = context.read<SavedCardsCubit>();
            final canAccept = state.quota.canAddMore;

            if (state.invitations.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    context.l10n.walletCardInvitationsEmpty,
                    textAlign: TextAlign.center,
                    style: textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      height: 1.4,
                    ),
                  ),
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              itemCount: state.invitations.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final invitation = state.invitations[index];
                return WalletCardInvitationCard(
                  invitation: invitation,
                  isResponding: state.respondingInvitationId == invitation.id,
                  canAccept: canAccept,
                  onAccept: () => cubit.respondToInvitation(
                    invitation: invitation,
                    accept: true,
                  ),
                  onReject: () => cubit.respondToInvitation(
                    invitation: invitation,
                    accept: false,
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
