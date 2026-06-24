import 'package:flutter/material.dart';
import '../../../../core/l10n/l10n_extensions.dart';

import '../../../../core/widgets/atoms/custom_text_field.dart';
import '../../domain/entities/onboarding_card_draft.dart';
import 'onboarding_card_preview_frame.dart';
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

class _OnboardingStepProfessionalState
    extends State<OnboardingStepProfessional> {
  late final TextEditingController _companyController;
  late final TextEditingController _titleController;

  @override
  void initState() {
    super.initState();
    _companyController =
        TextEditingController(text: widget.draft.company ?? '');
    _titleController = TextEditingController(text: widget.draft.title ?? '');
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

  void _notifyChanged() {
    widget.onChanged(
      widget.draft.copyWith(
        company: _companyController.text.trim().isEmpty
            ? null
            : _companyController.text.trim(),
        title: _titleController.text.trim().isEmpty
            ? null
            : _titleController.text.trim(),
      ),
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingStepShell(
      subtitle: context.l10n.kartnznnYzndeGrnecekBilgiler,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          OnboardingFieldLabel(label: context.l10n.irket, required: true),
          CustomTextField(
            controller: _companyController,
            autofocus: true,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.next,
            hintText: context.l10n.irketAdnGiriniz,
            prefixIcon: const Icon(Icons.business_outlined),
            onChanged: (_) => _notifyChanged(),
          ),
          const SizedBox(height: 16),
          OnboardingFieldLabel(label: context.l10n.pozisyon, required: true),
          CustomTextField(
            controller: _titleController,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.done,
            hintText: context.l10n.pozisyonunuzuGiriniz,
            prefixIcon: const Icon(Icons.work_outline_rounded),
            onChanged: (_) => _notifyChanged(),
          ),
          const SizedBox(height: 24),
          Center(
            child: OnboardingCardPreviewFrame(draft: widget.draft),
          ),
        ],
      ),
    );
  }
}
