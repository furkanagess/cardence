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
  bool _suppressDraftEmit = false;

  @override
  void initState() {
    super.initState();
    _companyController =
        TextEditingController(text: widget.draft.company ?? '');
    _titleController = TextEditingController(text: widget.draft.title ?? '');
    _companyController.addListener(_notifyChanged);
    _titleController.addListener(_notifyChanged);
  }

  @override
  void didUpdateWidget(OnboardingStepProfessional oldWidget) {
    super.didUpdateWidget(oldWidget);
    _suppressDraftEmit = true;
    if (oldWidget.draft.company != widget.draft.company &&
        _companyController.text != (widget.draft.company ?? '')) {
      _companyController.text = widget.draft.company ?? '';
    }
    if (oldWidget.draft.title != widget.draft.title &&
        _titleController.text != (widget.draft.title ?? '')) {
      _titleController.text = widget.draft.title ?? '';
    }
    _suppressDraftEmit = false;
  }

  @override
  void dispose() {
    _companyController
      ..removeListener(_notifyChanged)
      ..dispose();
    _titleController
      ..removeListener(_notifyChanged)
      ..dispose();
    super.dispose();
  }

  void _notifyChanged() {
    if (_suppressDraftEmit) return;
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
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingStepShell(
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
          ),
          const SizedBox(height: 16),
          OnboardingFieldLabel(label: context.l10n.pozisyon, required: true),
          CustomTextField(
            controller: _titleController,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.done,
            hintText: context.l10n.pozisyonunuzuGiriniz,
            prefixIcon: const Icon(Icons.work_outline_rounded),
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
