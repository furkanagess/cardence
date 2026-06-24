import 'package:flutter/material.dart';
import '../../../../core/l10n/l10n_extensions.dart';

import '../../../../core/widgets/molecules/card_color_customize_section.dart';
import '../../domain/entities/onboarding_card_draft.dart';
import 'onboarding_card_preview_frame.dart';
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
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return OnboardingStepShell(
      subtitle: context.l10n.kartnznDijitalKimliinizelletirin,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          OnboardingCardPreviewFrame(draft: draft),
          const SizedBox(height: 8),
          Center(
            child: Text(
              context.l10n.kartevirmekIinSaAlttaki,
              style: textTheme.labelMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(height: 24),
          CardColorCustomizeSection(
            backgroundColor: draft.backgroundColor,
            accentColor: draft.accentColor,
            lastUsedPaletteBackgroundColor:
                draft.lastUsedPaletteBackgroundColor,
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
        ],
      ),
    );
  }
}
