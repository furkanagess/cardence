import 'package:flutter/material.dart';
import '../../../../core/l10n/app_l10n.dart';
import '../../../../core/l10n/l10n_extensions.dart';
import '../../../../core/network/auth_api_exception.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/atoms/animated_success_check.dart';
import '../../../../core/widgets/atoms/custom_button.dart';
import '../../domain/entities/event_group.dart';
import 'event_group_card_id_invite_field.dart';

class InviteEventGroupCardsResult {
  const InviteEventGroupCardsResult({
    required this.group,
    required this.invitedCount,
    required this.invalidCount,
  });

  final EventGroup group;
  final int invitedCount;
  final int invalidCount;
}

enum _InviteSheetPhase { form, sending, success, error }

class InviteEventGroupCardsSheet extends StatefulWidget {
  const InviteEventGroupCardsSheet({
    super.key,
    required this.onSendInvites,
  });

  final Future<EventGroup> Function(List<String> cardIds) onSendInvites;

  static Future<InviteEventGroupCardsResult?> show(
    BuildContext context, {
    required Future<EventGroup> Function(List<String> cardIds) onSendInvites,
  }) {
    return showModalBottomSheet<InviteEventGroupCardsResult>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      isDismissible: false,
      enableDrag: false,
      useSafeArea: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => InviteEventGroupCardsSheet(
        onSendInvites: onSendInvites,
      ),
    );
  }

  @override
  State<InviteEventGroupCardsSheet> createState() =>
      _InviteEventGroupCardsSheetState();
}

class _InviteEventGroupCardsSheetState extends State<InviteEventGroupCardsSheet> {
  static const Duration _successDisplayDuration = Duration(milliseconds: 2400);

  late final TextEditingController _cardIdController;
  final Set<String> _invitedCardIds = {};
  _InviteSheetPhase _phase = _InviteSheetPhase.form;
  String? _errorMessage;
  InviteEventGroupCardsResult? _result;

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

  double _sheetHeight(BuildContext context) {
    return MediaQuery.sizeOf(context).height * 0.52;
  }

  void _addCardId(String cardId) {
    setState(() => _invitedCardIds.add(cardId));
  }

  Future<void> _submit() async {
    if (_invitedCardIds.isEmpty || _phase == _InviteSheetPhase.sending) return;

    final cardIds = _invitedCardIds.toList();
    setState(() {
      _phase = _InviteSheetPhase.sending;
      _errorMessage = null;
    });

    try {
      final updated = await widget.onSendInvites(cardIds);
      if (!mounted) return;

      final invalidCount = updated.invalidCardIds.length;
      final invitedCount = cardIds.length - invalidCount;
      final result = InviteEventGroupCardsResult(
        group: updated,
        invitedCount: invitedCount,
        invalidCount: invalidCount,
      );

      setState(() {
        _phase = _InviteSheetPhase.success;
        _result = result;
      });

      await Future<void>.delayed(_successDisplayDuration);
      if (!mounted) return;
      Navigator.of(context).pop(result);
    } on AuthApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _phase = _InviteSheetPhase.error;
        _errorMessage = e.message;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _phase = _InviteSheetPhase.error;
        _errorMessage = context.l10n.eventInviteSendFailed;
      });
    }
  }

  String _successMessage(BuildContext context) {
    final result = _result;
    if (result == null) return context.l10n.eventInvitesSentSuccess;

    final l10n = context.l10n;
    if (result.invitedCount > 0) {
      return AppL10n.eventCardsInvitedMessage(l10n, result.invitedCount);
    }
    if (result.invalidCount > 0) {
      return l10n.invalidCardId;
    }
    return l10n.eventInvitesSentSuccess;
  }

  String? _successSubtitle(BuildContext context) {
    final result = _result;
    if (result == null || result.invalidCount <= 0) return null;
    if (result.invitedCount <= 0) return null;
    return AppL10n.eventInvalidCardIdsMessage(
      context.l10n,
      result.invalidCount,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sheetHeight = _sheetHeight(context);
    final isSuccess = _phase == _InviteSheetPhase.success;
    final isSending = _phase == _InviteSheetPhase.sending;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: SafeArea(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOutCubic,
          height: sheetHeight,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (!isSuccess && !isSending) ...[
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
              ],
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 320),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  child: switch (_phase) {
                    _InviteSheetPhase.success => _SuccessView(
                        key: const ValueKey('success'),
                        message: _successMessage(context),
                        subtitle: _successSubtitle(context),
                      ),
                    _InviteSheetPhase.sending => _SendingView(
                        key: const ValueKey('sending'),
                      ),
                    _ => _FormBody(
                        key: const ValueKey('form'),
                        colorScheme: colorScheme,
                        isDark: isDark,
                        cardIdController: _cardIdController,
                        invitedCardIds: _invitedCardIds,
                        errorMessage: _errorMessage,
                        onAdd: _addCardId,
                        onRemove: (cardId) {
                          setState(() => _invitedCardIds.remove(cardId));
                        },
                      ),
                  },
                ),
              ),
              if (!isSuccess && !isSending)
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
      ),
    );
  }
}

class _FormBody extends StatelessWidget {
  const _FormBody({
    super.key,
    required this.colorScheme,
    required this.isDark,
    required this.cardIdController,
    required this.invitedCardIds,
    required this.errorMessage,
    required this.onAdd,
    required this.onRemove,
  });

  final ColorScheme colorScheme;
  final bool isDark;
  final TextEditingController cardIdController;
  final Set<String> invitedCardIds;
  final String? errorMessage;
  final ValueChanged<String> onAdd;
  final ValueChanged<String> onRemove;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DecoratedBox(
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
                controller: cardIdController,
                invitedCardIds: invitedCardIds,
                onAdd: onAdd,
                onRemove: onRemove,
              ),
            ),
          ),
          if (errorMessage != null) ...[
            const SizedBox(height: 10),
            Text(
              errorMessage!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.error,
                  ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SendingView extends StatelessWidget {
  const _SendingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 20),
          Text(
            context.l10n.eventSendingInvites,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}

class _SuccessView extends StatelessWidget {
  const _SuccessView({
    super.key,
    required this.message,
    this.subtitle,
  });

  final String message;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const AnimatedSuccessCheck(size: 104),
            const SizedBox(height: 28),
            Text(
              context.l10n.eventInvitesSentSuccess,
              textAlign: TextAlign.center,
              style: textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              message,
              textAlign: TextAlign.center,
              style: textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.4,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.85),
                  height: 1.35,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
