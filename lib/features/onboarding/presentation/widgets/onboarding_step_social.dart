import 'package:flutter/material.dart';

import '../../domain/entities/onboarding_card_draft.dart';

class OnboardingStepSocial extends StatefulWidget {
  const OnboardingStepSocial({
    super.key,
    required this.draft,
    required this.onChanged,
  });

  final OnboardingCardDraft draft;
  final ValueChanged<OnboardingCardDraft> onChanged;

  @override
  State<OnboardingStepSocial> createState() => _OnboardingStepSocialState();
}

class _OnboardingStepSocialState extends State<OnboardingStepSocial> {
  late final TextEditingController _websiteController;
  late final TextEditingController _linkedinController;

  @override
  void initState() {
    super.initState();
    _websiteController =
        TextEditingController(text: widget.draft.website ?? '');
    _linkedinController =
        TextEditingController(text: widget.draft.linkedin ?? '');
  }

  @override
  void didUpdateWidget(OnboardingStepSocial oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.draft.website != widget.draft.website &&
        _websiteController.text != (widget.draft.website ?? '')) {
      _websiteController.text = widget.draft.website ?? '';
    }
    if (oldWidget.draft.linkedin != widget.draft.linkedin &&
        _linkedinController.text != (widget.draft.linkedin ?? '')) {
      _linkedinController.text = widget.draft.linkedin ?? '';
    }
  }

  @override
  void dispose() {
    _websiteController.dispose();
    _linkedinController.dispose();
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
            'Web & Sosyal',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'İstersen web siteni ve LinkedIn profilini ekle.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 24),
          TextField(
            keyboardType: TextInputType.url,
            autocorrect: false,
            decoration: const InputDecoration(
              hintText: 'Web sitesi (https://...)',
              prefixIcon: Icon(Icons.language),
            ),
            controller: _websiteController,
            onChanged: (value) => widget.onChanged(
              widget.draft.copyWith(website: value.isEmpty ? null : value),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            keyboardType: TextInputType.url,
            autocorrect: false,
            decoration: const InputDecoration(
              hintText: 'LinkedIn profil linki',
              prefixIcon: Icon(Icons.link),
            ),
            controller: _linkedinController,
            onChanged: (value) => widget.onChanged(
              widget.draft.copyWith(linkedin: value.isEmpty ? null : value),
            ),
          ),
        ],
      ),
    );
  }
}
