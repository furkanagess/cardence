import 'package:flutter/material.dart';

import '../../../../core/l10n/l10n_extensions.dart';
import '../../domain/entities/wallet_card_invitation.dart';
import 'wallet_card_invitation_card.dart';

class WalletCardInvitationsSection extends StatelessWidget {
  const WalletCardInvitationsSection({
    super.key,
    required this.invitations,
    required this.respondingInvitationId,
    required this.canAccept,
    required this.onAccept,
    required this.onReject,
  });

  final List<WalletCardInvitation> invitations;
  final String? respondingInvitationId;
  final bool canAccept;
  final ValueChanged<WalletCardInvitation> onAccept;
  final ValueChanged<WalletCardInvitation> onReject;

  @override
  Widget build(BuildContext context) {
    if (invitations.isEmpty) return const SizedBox.shrink();

    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final title = context.l10n.walletCardInvitationsSection.toUpperCase();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text(
              title,
              style: textTheme.labelLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
              ),
            ),
          ),
          for (var index = 0; index < invitations.length; index++) ...[
            if (index > 0) const SizedBox(height: 10),
            WalletCardInvitationCard(
              invitation: invitations[index],
              isResponding: respondingInvitationId == invitations[index].id,
              canAccept: canAccept,
              onAccept: () => onAccept(invitations[index]),
              onReject: () => onReject(invitations[index]),
            ),
          ],
        ],
      ),
    );
  }
}
