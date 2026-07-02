import 'package:flutter/material.dart';
import '../../../../core/l10n/l10n_extensions.dart';

import '../../../../core/widgets/atoms/custom_text_field.dart';
import '../../../../core/widgets/molecules/skills_chip_input.dart';
import '../../domain/entities/onboarding_card_draft.dart';
import 'onboarding_step_shell.dart';

/// İsteğe bağlı kişisel profil alanları.
class OnboardingStepOptional extends StatefulWidget {
  const OnboardingStepOptional({
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
  State<OnboardingStepOptional> createState() => _OnboardingStepOptionalState();
}

class _OnboardingStepOptionalState extends State<OnboardingStepOptional> {
  late final TextEditingController _cityController;
  late final TextEditingController _schoolController;
  late final TextEditingController _linkedinController;
  late final TextEditingController _aboutController;

  @override
  void initState() {
    super.initState();
    _cityController = TextEditingController(text: widget.draft.city ?? '');
    _schoolController = TextEditingController(text: widget.draft.school ?? '');
    _linkedinController =
        TextEditingController(text: widget.draft.linkedin ?? '');
    _aboutController = TextEditingController(text: widget.draft.about ?? '');
  }

  @override
  void dispose() {
    _cityController.dispose();
    _schoolController.dispose();
    _linkedinController.dispose();
    _aboutController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return OnboardingStepShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          OnboardingFieldLabel(label: l10n.ehir),
          CustomTextField(
            controller: _cityController,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.next,
            hintText: l10n.savedCardFieldHintCity,
            prefixIcon: const Icon(Icons.location_city_outlined),
            onChanged: (value) => widget.onChanged(
              widget.draft.copyWith(city: value.trim().isEmpty ? null : value.trim()),
            ),
          ),
          const SizedBox(height: 12),
          OnboardingFieldLabel(label: l10n.okul),
          CustomTextField(
            controller: _schoolController,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.next,
            hintText: l10n.savedCardFieldHintSchool,
            prefixIcon: const Icon(Icons.school_outlined),
            onChanged: (value) => widget.onChanged(
              widget.draft.copyWith(
                school: value.trim().isEmpty ? null : value.trim(),
              ),
            ),
          ),
          const SizedBox(height: 12),
          OnboardingFieldLabel(label: l10n.linkedin),
          CustomTextField(
            controller: _linkedinController,
            keyboardType: TextInputType.url,
            autocorrect: false,
            textInputAction: TextInputAction.next,
            hintText: l10n.savedCardFieldHintLinkedin,
            prefixIcon: const Icon(Icons.link_rounded),
            onChanged: (value) => widget.onChanged(
              widget.draft.copyWith(
                linkedin: value.trim().isEmpty ? null : value.trim(),
              ),
            ),
          ),
          const SizedBox(height: 12),
          OnboardingFieldLabel(label: l10n.hakkmda),
          CustomTextField(
            controller: _aboutController,
            minLines: 2,
            maxLines: 3,
            maxLength: 200,
            textCapitalization: TextCapitalization.sentences,
            hintText: l10n.savedCardFieldHintAbout,
            onChanged: (value) => widget.onChanged(
              widget.draft.copyWith(
                about: value.trim().isEmpty ? null : value.trim(),
              ),
            ),
          ),
          const SizedBox(height: 12),
          OnboardingFieldLabel(label: l10n.beceriler),
          SkillsChipInput(
            label: '',
            hintText: l10n.beceriEkle,
            value: widget.draft.skills,
            onChanged: (s) => widget.onChanged(
              widget.draft.copyWith(
                skills: (s ?? '').trim().isEmpty ? null : s,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
