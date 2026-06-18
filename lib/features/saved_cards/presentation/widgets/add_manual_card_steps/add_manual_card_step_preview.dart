import 'package:flutter/material.dart';

import '../../../../../core/widgets/molecules/card_color_customize_section.dart';
import '../../../../onboarding/presentation/widgets/onboarding_card_preview_frame.dart';
import '../../../../onboarding/presentation/widgets/onboarding_step_shell.dart';
import '../../../domain/entities/manual_saved_card_draft.dart';
import '../../manual_saved_card_preview_helper.dart';

class AddManualCardStepPreview extends StatelessWidget {
  const AddManualCardStepPreview({
    super.key,
    required this.draft,
    required this.onChanged,
  });

  final ManualSavedCardDraft draft;
  final ValueChanged<ManualSavedCardDraft> onChanged;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final previewDraft = ManualSavedCardPreviewHelper.toPreviewDraft(draft);

    return OnboardingStepShell(
      subtitle: 'Kartı kaydetmeden önce son kez kontrol edin.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          OnboardingCardPreviewFrame(
            draft: previewDraft,
            flipOnTouch: true,
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              'Kartı çevirmek için sağ alttaki ikona dokunun',
              style: textTheme.labelMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(height: 24),
          CardColorCustomizeSection(
            backgroundColor: draft.backgroundColor,
            accentColor: draft.accentColor,
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
          ),
        ],
      ),
    );
  }
}
