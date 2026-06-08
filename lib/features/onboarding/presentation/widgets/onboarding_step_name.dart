import 'package:flutter/material.dart';

import '../../../../core/widgets/atoms/custom_text_field.dart';
import '../../domain/entities/onboarding_card_draft.dart';
import '../onboarding_name_helper.dart';
import 'onboarding_step_shell.dart';

class OnboardingStepName extends StatefulWidget {
  const OnboardingStepName({
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
  State<OnboardingStepName> createState() => _OnboardingStepNameState();
}

class _OnboardingStepNameState extends State<OnboardingStepName> {
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;

  @override
  void initState() {
    super.initState();
    final parts = OnboardingNameHelper.split(widget.draft.displayName);
    _firstNameController = TextEditingController(text: parts.first);
    _lastNameController = TextEditingController(text: parts.last);
  }

  @override
  void didUpdateWidget(OnboardingStepName oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.draft.displayName != widget.draft.displayName) {
      final parts = OnboardingNameHelper.split(widget.draft.displayName);
      if (_firstNameController.text != parts.first) {
        _firstNameController.text = parts.first;
      }
      if (_lastNameController.text != parts.last) {
        _lastNameController.text = parts.last;
      }
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  void _emitDisplayName() {
    final combined = OnboardingNameHelper.combine(
      _firstNameController.text,
      _lastNameController.text,
    );
    widget.onChanged(
      widget.draft.copyWith(
        displayName: combined.isEmpty ? null : combined,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingStepShell(
      title: 'Adınız',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const OnboardingFieldLabel(label: 'Ad', required: true),
          CustomTextField(
            controller: _firstNameController,
            autofocus: true,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.next,
            hintText: 'Örn. Ayşe',
            prefixIcon: const Icon(Icons.person_outline),
            onChanged: (_) => _emitDisplayName(),
          ),
          const SizedBox(height: 16),
          const OnboardingFieldLabel(label: 'Soyad', required: true),
          CustomTextField(
            controller: _lastNameController,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.done,
            hintText: 'Örn. Yılmaz',
            prefixIcon: const Icon(Icons.person_outline),
            onChanged: (_) => _emitDisplayName(),
          ),
        ],
      ),
    );
  }
}
