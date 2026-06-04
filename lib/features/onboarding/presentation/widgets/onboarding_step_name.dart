import 'package:flutter/material.dart';

import '../../domain/entities/onboarding_card_draft.dart';

class OnboardingStepName extends StatefulWidget {
  const OnboardingStepName({
    super.key,
    required this.draft,
    required this.onChanged,
  });

  final OnboardingCardDraft draft;
  final ValueChanged<OnboardingCardDraft> onChanged;

  @override
  State<OnboardingStepName> createState() => _OnboardingStepNameState();
}

class _OnboardingStepNameState extends State<OnboardingStepName> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.draft.displayName ?? '');
  }

  @override
  void didUpdateWidget(OnboardingStepName oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.draft.displayName != widget.draft.displayName &&
        _controller.text != (widget.draft.displayName ?? '')) {
      _controller.text = widget.draft.displayName ?? '';
    }
  }

  @override
  void dispose() {
    _controller.dispose();
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
            'Adın',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Kartında görünecek adını veya unvanını gir.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 24),
          TextField(
            autofocus: true,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              hintText: 'Örn. Ayşe Yılmaz',
              prefixIcon: Icon(Icons.person_outline),
            ),
            controller: _controller,
            onChanged: (value) => widget.onChanged(
              widget.draft.copyWith(
                displayName: value.isEmpty ? null : value,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
