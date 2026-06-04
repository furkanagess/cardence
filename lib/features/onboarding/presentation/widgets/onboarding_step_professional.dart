import 'package:flutter/material.dart';

import '../../../../core/widgets/molecules/skills_chip_input.dart';
import '../../domain/entities/onboarding_card_draft.dart';

class OnboardingStepProfessional extends StatefulWidget {
  const OnboardingStepProfessional({
    super.key,
    required this.draft,
    required this.onChanged,
  });

  final OnboardingCardDraft draft;
  final ValueChanged<OnboardingCardDraft> onChanged;

  @override
  State<OnboardingStepProfessional> createState() =>
      _OnboardingStepProfessionalState();
}

class _OnboardingStepProfessionalState extends State<OnboardingStepProfessional> {
  late final TextEditingController _companyController;
  late final TextEditingController _titleController;
  late final TextEditingController _schoolController;
  late final TextEditingController _aboutController;

  @override
  void initState() {
    super.initState();
    _companyController =
        TextEditingController(text: widget.draft.company ?? '');
    _titleController =
        TextEditingController(text: widget.draft.title ?? '');
    _schoolController =
        TextEditingController(text: widget.draft.school ?? '');
    _aboutController =
        TextEditingController(text: widget.draft.about ?? '');
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
    if (oldWidget.draft.school != widget.draft.school &&
        _schoolController.text != (widget.draft.school ?? '')) {
      _schoolController.text = widget.draft.school ?? '';
    }
    if (oldWidget.draft.about != widget.draft.about &&
        _aboutController.text != (widget.draft.about ?? '')) {
      _aboutController.text = widget.draft.about ?? '';
    }
  }

  @override
  void dispose() {
    _companyController.dispose();
    _titleController.dispose();
    _schoolController.dispose();
    _aboutController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Profesyonel Bilgiler',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Şirket, ünvan, okul ve hakkımda bilgilerin kartında görünsün.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 24),
          TextField(
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              hintText: 'Şirket adı',
              prefixIcon: Icon(Icons.business_outlined),
            ),
            controller: _companyController,
            onChanged: (value) => widget.onChanged(
              widget.draft.copyWith(company: value.isEmpty ? null : value),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              hintText: 'Ünvan (örn. Yazılım Geliştirici)',
              prefixIcon: Icon(Icons.badge_outlined),
            ),
            controller: _titleController,
            onChanged: (value) => widget.onChanged(
              widget.draft.copyWith(title: value.isEmpty ? null : value),
            ),
          ),
          const SizedBox(height: 16),
          SkillsChipInput(
            label: 'Yetenekler',
            hintText: 'Yetenek ekle (örn. Flutter)',
            value: widget.draft.skills,
            onChanged: (s) => widget.onChanged(
              widget.draft.copyWith(skills: (s ?? '').trim().isEmpty ? null : s),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              hintText: 'Okul (örn. İstanbul Üniversitesi)',
              prefixIcon: Icon(Icons.school_outlined),
            ),
            controller: _schoolController,
            onChanged: (value) => widget.onChanged(
              widget.draft.copyWith(school: value.isEmpty ? null : value),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            minLines: 4,
            maxLines: 8,
            maxLength: 200,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              hintText: 'Kısaca kendinizi tanıtın (hakkımda)',
              prefixIcon: Icon(Icons.person_outline_rounded),
              alignLabelWithHint: true,
            ),
            controller: _aboutController,
            onChanged: (value) => widget.onChanged(
              widget.draft.copyWith(about: value.isEmpty ? null : value),
            ),
          ),
        ],
      ),
    );
  }
}
