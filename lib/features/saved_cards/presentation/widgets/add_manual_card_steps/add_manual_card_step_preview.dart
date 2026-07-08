import 'package:flutter/material.dart';
import '../../../../../core/l10n/l10n_extensions.dart';

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
    final previewDraft = ManualSavedCardPreviewHelper.toPreviewDraft(draft);

    return OnboardingStepShell(
      subtitle: context.l10n.kartKaydetmedennceSonKez,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          OnboardingCardPreviewFrame(
            draft: previewDraft,
            showActionStrip: false,
          ),
          const SizedBox(height: 24),
          CardColorCustomizeSection(
            backgroundColor: draft.backgroundColor,
            accentColor: draft.accentColor,
            previewBuilder: (bg, accent) => OnboardingCardPreviewFrame(
              draft: ManualSavedCardPreviewHelper.toPreviewDraft(
                draft.copyWith(
                  backgroundColor: bg,
                  accentColor: accent,
                  clearBackgroundColor: bg == null,
                  clearAccentColor: accent == null,
                ),
              ),
              showActionStrip: false,
            ),
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
