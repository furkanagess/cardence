import 'package:flutter/material.dart';

import '../../../../core/l10n/l10n_extensions.dart';
import '../../../../core/widgets/atoms/cardence_app_bar.dart';
import '../../../../core/widgets/organisms/cardence_scaffold.dart';
import '../../domain/entities/event_group_outbound_invitation.dart';
import '../widgets/event_group_outbound_invitee_tile.dart';

/// Etkinlik detayındaki davet edilenlerin kişi kişi listesi.
class EventGroupInvitedListPage extends StatelessWidget {
  const EventGroupInvitedListPage({
    super.key,
    required this.invitations,
  });

  final List<EventGroupOutboundInvitation> invitations;

  static Future<void> open(
    BuildContext context, {
    required List<EventGroupOutboundInvitation> invitations,
  }) {
    return Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => EventGroupInvitedListPage(invitations: invitations),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return CardenceScaffold(
      appBar: CardenceAppBar(
        title: context.l10n.eventOutboundInvitesListTitle,
      ),
      body: invitations.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  context.l10n.eventOutboundInvitesEmpty,
                  textAlign: TextAlign.center,
                  style: textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              itemCount: invitations.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                return EventGroupOutboundInviteeTile(
                  invitation: invitations[index],
                );
              },
            ),
    );
  }
}
