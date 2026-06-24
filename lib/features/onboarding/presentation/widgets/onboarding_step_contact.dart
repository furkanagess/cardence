import 'package:flutter/material.dart';
import '../../../../core/l10n/l10n_extensions.dart';

import '../../../../core/widgets/atoms/custom_text_field.dart';
import '../../domain/entities/onboarding_card_draft.dart';
import 'onboarding_step_shell.dart';

class OnboardingStepContact extends StatefulWidget {
  const OnboardingStepContact({
    super.key,
    required this.draft,
    required this.onChanged,
    required this.stepIndex,
    required this.stepCount,
  });

  final OnboardingCardDraft draft;
  final ValueChanged<OnboardingCardDraft> onChanged;
  final int stepIndex;
  final int stepCount;

  @override
  State<OnboardingStepContact> createState() => _OnboardingStepContactState();
}

class _OnboardingStepContactState extends State<OnboardingStepContact> {
  late final TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.draft.email ?? '');
  }

  @override
  void didUpdateWidget(OnboardingStepContact oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.draft.email != widget.draft.email &&
        _emailController.text != (widget.draft.email ?? '')) {
      _emailController.text = widget.draft.email ?? '';
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Stack(
      children: [
        Positioned(
          left: 0,
          right: 0,
          top: 48,
          child: IgnorePointer(
            child: Icon(
              Icons.alternate_email_rounded,
              size: 180,
              color: colorScheme.primary.withValues(alpha: 0.06),
            ),
          ),
        ),
        OnboardingStepShell(
          subtitle: context.l10n.iletiimIinEPostaAdresiniz,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              OnboardingFieldLabel(label: context.l10n.ePosta, required: true),
              CustomTextField(
                controller: _emailController,
                autofocus: true,
                keyboardType: TextInputType.emailAddress,
                autocorrect: false,
                textInputAction: TextInputAction.done,
                hintText: context.l10n.ePosta,
                prefixIcon: const Icon(Icons.alternate_email_rounded),
                onChanged: (value) => widget.onChanged(
                  widget.draft.copyWith(
                    email: value.isEmpty ? null : value.trim(),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                context.l10n.iOrtaklklarVeGvenlikBildirimleri,
                style: textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
