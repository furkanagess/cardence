import 'package:flutter/material.dart';

import '../../../../../core/widgets/atoms/custom_text_field.dart';
import '../../../../onboarding/presentation/onboarding_name_helper.dart';
import '../../../../onboarding/presentation/widgets/onboarding_card_preview_frame.dart';
import '../../../../onboarding/presentation/widgets/onboarding_step_shell.dart';
import '../../../domain/entities/manual_saved_card_draft.dart';
import '../../manual_saved_card_preview_helper.dart';

class AddManualCardStepName extends StatefulWidget {
  const AddManualCardStepName({
    super.key,
    required this.draft,
    required this.onChanged,
  });

  final ManualSavedCardDraft draft;
  final ValueChanged<ManualSavedCardDraft> onChanged;

  @override
  State<AddManualCardStepName> createState() => _AddManualCardStepNameState();
}

class _AddManualCardStepNameState extends State<AddManualCardStepName> {
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
  void didUpdateWidget(AddManualCardStepName oldWidget) {
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

  ManualSavedCardDraft get _previewDraft {
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
      subtitle: 'Kartvizitte görünen adı girin',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const OnboardingFieldLabel(label: 'Ad', required: true),
          CustomTextField(
            controller: _firstNameController,
            autofocus: true,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.next,
            hintText: 'Örn: Mehmet',
            prefixIcon: const Icon(Icons.person_outline),
            onChanged: (_) {
              _emitDisplayName();
              setState(() {});
            },
          ),
          const SizedBox(height: 16),
          const OnboardingFieldLabel(label: 'Soyad', required: true),
          CustomTextField(
            controller: _lastNameController,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.done,
            hintText: 'Örn: Yılmaz',
            prefixIcon: const Icon(Icons.person_outline),
            onChanged: (_) {
              _emitDisplayName();
              setState(() {});
            },
          ),
          const SizedBox(height: 24),
          Center(
            child: OnboardingCardPreviewFrame(
              draft: ManualSavedCardPreviewHelper.toPreviewDraft(_previewDraft),
            ),
          ),
        ],
      ),
    );
  }
}
