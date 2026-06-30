import 'package:flutter/material.dart';
import '../../../../core/l10n/l10n_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/atoms/custom_button.dart';
import 'event_group_card_id_invite_field.dart';

class InviteEventGroupCardsSheet extends StatefulWidget {
  const InviteEventGroupCardsSheet({super.key});

  static Future<List<String>?> show(BuildContext context) {
    return showModalBottomSheet<List<String>>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      useSafeArea: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => const InviteEventGroupCardsSheet(),
    );
  }

  @override
  State<InviteEventGroupCardsSheet> createState() =>
      _InviteEventGroupCardsSheetState();
}

class _InviteEventGroupCardsSheetState extends State<InviteEventGroupCardsSheet> {
  late final TextEditingController _cardIdController;
  final Set<String> _invitedCardIds = {};

  @override
  void initState() {
    super.initState();
    _cardIdController = TextEditingController();
  }

  @override
  void dispose() {
    _cardIdController.dispose();
    super.dispose();
  }

  void _addCardId() {
    final cardId = _cardIdController.text.trim();
    if (cardId.isEmpty) return;
    setState(() {
      _invitedCardIds.add(cardId);
      _cardIdController.clear();
    });
  }

  void _submit() {
    if (_invitedCardIds.isEmpty) return;
    Navigator.of(context).pop(_invitedCardIds.toList());
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
              child: Text(
                context.l10n.eventInviteCardsTitle,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: Text(
                context.l10n.eventInviteCardsSubtitle,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerLowest.withValues(
                    alpha: isDark ? 0.55 : 0.85,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark
                        ? AppColors.outlineDark.withValues(alpha: 0.35)
                        : AppColors.outlineVariant.withValues(alpha: 0.75),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: EventGroupCardIdInviteField(
                    controller: _cardIdController,
                    invitedCardIds: _invitedCardIds,
                    onAdd: _addCardId,
                    onRemove: (cardId) {
                      setState(() => _invitedCardIds.remove(cardId));
                    },
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: CustomButton(
                label: context.l10n.eventSendInvites,
                icon: Icons.send_rounded,
                onPressed: _invitedCardIds.isEmpty ? null : _submit,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
