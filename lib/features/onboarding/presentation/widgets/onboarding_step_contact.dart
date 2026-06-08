import 'package:flutter/material.dart';

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
    _emailController =
        TextEditingController(text: widget.draft.email ?? '');
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
    return OnboardingStepShell(
      title: 'E-posta',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const OnboardingFieldLabel(label: 'E-posta', required: true),
          CustomTextField(
            controller: _emailController,
            autofocus: true,
            keyboardType: TextInputType.emailAddress,
            autocorrect: false,
            textInputAction: TextInputAction.done,
            hintText: 'ornek@sirket.com',
            prefixIcon: const Icon(Icons.alternate_email_rounded),
            onChanged: (value) => widget.onChanged(
              widget.draft.copyWith(
                email: value.isEmpty ? null : value.trim(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
