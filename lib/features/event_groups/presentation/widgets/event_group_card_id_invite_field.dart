import 'package:flutter/material.dart';
import '../../../../core/l10n/l10n_extensions.dart';
import '../../../../core/widgets/atoms/custom_button.dart';
import '../../../../core/widgets/atoms/custom_text_field.dart';

class EventGroupCardIdInviteField extends StatelessWidget {
  const EventGroupCardIdInviteField({
    super.key,
    required this.controller,
    required this.invitedCardIds,
    required this.onAdd,
    required this.onRemove,
  });

  final TextEditingController controller;
  final Set<String> invitedCardIds;
  final VoidCallback onAdd;
  final ValueChanged<String> onRemove;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                controller: controller,
                labelText: context.l10n.eventInviteByCardId,
                hintText: context.l10n.eventCardIdHint,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => onAdd(),
              ),
            ),
            const SizedBox(width: 10),
            CustomButton.tonal(
              label: context.l10n.ekle,
              icon: Icons.add_rounded,
              onPressed: onAdd,
              fullWidth: false,
            ),
          ],
        ),
        if (invitedCardIds.isNotEmpty) ...[
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: invitedCardIds
                .map(
                  (cardId) => InputChip(
                    label: Text(cardId),
                    onDeleted: () => onRemove(cardId),
                  ),
                )
                .toList(),
          ),
        ],
        if (invitedCardIds.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            context.l10n.eventInvitedCardIdsCount(invitedCardIds.length),
            style: textTheme.labelMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }
}
