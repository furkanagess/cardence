import 'package:flutter/material.dart';

import '../../domain/entities/onboarding_card_draft.dart';
import '../onboarding_preview_helpers.dart';
import 'onboarding_step_shell.dart';

class OnboardingStepPreview extends StatelessWidget {
  const OnboardingStepPreview({
    super.key,
    required this.draft,
    required this.stepIndex,
    required this.stepCount,
  });

  final OnboardingCardDraft draft;
  final int stepIndex;
  final int stepCount;

  @override
  Widget build(BuildContext context) {
    return OnboardingStepShell(
      title: 'Önizleme',
      subtitle: 'Kartınız böyle görünecek.',
      child: OnboardingPreviewHelpers.preview(draft),
    );
  }
}
