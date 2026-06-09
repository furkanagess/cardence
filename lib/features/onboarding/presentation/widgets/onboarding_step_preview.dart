import 'package:flutter/material.dart';

import '../../../../core/widgets/molecules/card_color_customize_section.dart';
import '../../../../core/widgets/organisms/flippable_person_card.dart';
import '../../domain/entities/onboarding_card_draft.dart';
import '../onboarding_preview_helpers.dart';
import 'onboarding_step_shell.dart';

class OnboardingStepPreview extends StatelessWidget {
  const OnboardingStepPreview({
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
  Widget build(BuildContext context) {
    return OnboardingStepShell(
      title: 'Kart önizlemesi',
      subtitle: 'Kartınızın görünümünü kontrol edin ve renkleri seçin.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: OnboardingPreviewHelpers.preview(draft),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              'Canlı önizleme',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ),
          const SizedBox(height: 24),
          CardColorCustomizeSection(
            backgroundColor: draft.backgroundColor,
            accentColor: draft.accentColor,
            lastUsedPaletteBackgroundColor: draft.lastUsedPaletteBackgroundColor,
            onBackgroundColorChanged: (hex) {
              onChanged(
                hex == null
                    ? draft.copyWith(clearBackgroundColor: true)
                    : draft.copyWith(backgroundColor: hex),
              );
            },
            onAccentColorChanged: (hex) {
              onChanged(
                hex == null
                    ? draft.copyWith(clearAccentColor: true)
                    : draft.copyWith(accentColor: hex),
              );
            },
            onLastUsedPaletteBackgroundChanged: (hex) {
              onChanged(
                draft.copyWith(lastUsedPaletteBackgroundColor: hex),
              );
            },
          ),
          const SizedBox(height: FlippablePersonCard.fixedHeight * 0.05),
        ],
      ),
    );
  }
}
