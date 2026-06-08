import 'package:flutter/material.dart';

import '../../../../core/widgets/atoms/custom_text_field.dart';
import '../../domain/entities/onboarding_card_draft.dart';
import 'onboarding_step_shell.dart';

class OnboardingStepProfessional extends StatefulWidget {
  const OnboardingStepProfessional({
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
  State<OnboardingStepProfessional> createState() =>
      _OnboardingStepProfessionalState();
}

class _OnboardingStepProfessionalState extends State<OnboardingStepProfessional> {
  late final TextEditingController _companyController;
  late final TextEditingController _titleController;

  @override
  void initState() {
    super.initState();
    _companyController =
        TextEditingController(text: widget.draft.company ?? '');
    _titleController =
        TextEditingController(text: widget.draft.title ?? '');
  }

  @override
  void didUpdateWidget(OnboardingStepProfessional oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.draft.company != widget.draft.company &&
        _companyController.text != (widget.draft.company ?? '')) {
      _companyController.text = widget.draft.company ?? '';
    }
    if (oldWidget.draft.title != widget.draft.title &&
        _titleController.text != (widget.draft.title ?? '')) {
      _titleController.text = widget.draft.title ?? '';
    }
  }

  @override
  void dispose() {
    _companyController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingStepShell(
      title: 'İş bilgileri',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const OnboardingFieldLabel(label: 'Şirket', required: true),
          CustomTextField(
            controller: _companyController,
            autofocus: true,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.next,
            hintText: 'Örn. Cardence A.Ş.',
            prefixIcon: const Icon(Icons.business_outlined),
            onChanged: (value) => widget.onChanged(
              widget.draft.copyWith(company: value.isEmpty ? null : value.trim()),
            ),
          ),
          const SizedBox(height: 16),
          const OnboardingFieldLabel(label: 'Pozisyon', required: true),
          CustomTextField(
            controller: _titleController,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.done,
            hintText: 'Örn. Ürün Müdürü',
            prefixIcon: const Icon(Icons.work_outline_rounded),
            onChanged: (value) => widget.onChanged(
              widget.draft.copyWith(title: value.isEmpty ? null : value.trim()),
            ),
          ),
        ],
      ),
    );
  }
}
