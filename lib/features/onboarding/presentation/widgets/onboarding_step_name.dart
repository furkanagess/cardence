import 'package:flutter/material.dart';
import '../../../../core/l10n/l10n_extensions.dart';

import '../../../../core/widgets/atoms/custom_text_field.dart';
import '../../domain/entities/onboarding_card_draft.dart';
import '../onboarding_name_helper.dart';
import 'onboarding_card_preview_frame.dart';
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
  late final Listenable _previewListenable;
  bool _suppressDraftEmit = false;

  @override
  void initState() {
    super.initState();
    final parts = OnboardingNameHelper.split(widget.draft.displayName);
    _firstNameController = TextEditingController(text: parts.first);
    _lastNameController = TextEditingController(text: parts.last);
    _previewListenable =
        Listenable.merge([_firstNameController, _lastNameController]);
    _firstNameController.addListener(_emitDisplayName);
    _lastNameController.addListener(_emitDisplayName);
  }

  @override
  void didUpdateWidget(OnboardingStepName oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.draft.displayName != widget.draft.displayName) {
      final parts = OnboardingNameHelper.split(widget.draft.displayName);
      _suppressDraftEmit = true;
      if (_firstNameController.text != parts.first) {
        _firstNameController.text = parts.first;
      }
      if (_lastNameController.text != parts.last) {
        _lastNameController.text = parts.last;
      }
      _suppressDraftEmit = false;
    }
  }

  @override
  void dispose() {
    _firstNameController
      ..removeListener(_emitDisplayName)
      ..dispose();
    _lastNameController
      ..removeListener(_emitDisplayName)
      ..dispose();
    super.dispose();
  }

  void _emitDisplayName() {
    if (_suppressDraftEmit) return;
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

  OnboardingCardDraft get _previewDraft {
    final combined = OnboardingNameHelper.combine(
      _firstNameController.text,
      _lastNameController.text,
    );
    return widget.draft.copyWith(
      displayName: combined.isEmpty ? null : combined,
    );
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingStepShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          OnboardingFieldLabel(label: 'Ad', required: true),
          CustomTextField(
            controller: _firstNameController,
            autofocus: true,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.next,
            hintText: context.l10n.rnMehmet,
            prefixIcon: const Icon(Icons.person_outline),
          ),
          const SizedBox(height: 16),
          OnboardingFieldLabel(label: context.l10n.soyad, required: true),
          CustomTextField(
            controller: _lastNameController,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.done,
            hintText: context.l10n.rnYlmaz,
            prefixIcon: const Icon(Icons.person_outline),
          ),
          const SizedBox(height: 24),
          ListenableBuilder(
            listenable: _previewListenable,
            builder: (context, _) {
              return Center(
                child: OnboardingCardPreviewFrame(draft: _previewDraft),
              );
            },
          ),
        ],
      ),
    );
  }
}
