import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/l10n/l10n_extensions.dart';

import '../../../../core/widgets/molecules/card_appearance_customize_section.dart';
import '../../../../core/widgets/molecules/card_effect_customize_section.dart';
import '../../domain/entities/onboarding_card_draft.dart';
import '../../../saved_cards/domain/usecases/upgrade_wallet_plan.dart';
import '../cubit/onboarding_cubit.dart';
import 'onboarding_card_preview_frame.dart';

class OnboardingStepPreview extends StatelessWidget {
  const OnboardingStepPreview({
    super.key,
    required this.draft,
    required this.stepIndex,
    required this.stepCount,
    required this.upgradeWalletPlan,
  });

  final OnboardingCardDraft draft;
  final int stepIndex;
  final int stepCount;
  final UpgradeWalletPlan upgradeWalletPlan;

  static const double _horizontalInset = 20;

  void _applyDraft(BuildContext context, OnboardingCardDraft next) {
    context.read<OnboardingCubit>().updateDraftImmediate(next);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(_horizontalInset, 0, _horizontalInset, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              OnboardingCardPreviewFrame(draft: draft),
              const SizedBox(height: 4),
              Center(
                child: Text(
                  context.l10n.kartevirmekIinSaAlttaki,
                  style: textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              CardAppearanceCustomizeSection(
                backgroundColor: draft.backgroundColor,
                accentColor: draft.accentColor,
                cardEffect: draft.cardEffect,
                compact: true,
                showDefaultColorChips: false,
                presetColorOptionLimit: 4,
                singleRowColorChips: true,
                showPaletteButtons: true,
                showRandomBackgroundColorChip: true,
                showRandomTextColorChip: true,
                colorChipSize: 40,
                showEffectSection: false,
                lastUsedPaletteBackgroundColor:
                    draft.lastUsedPaletteBackgroundColor,
                showInlinePreview: false,
                previewBuilder: (bg, accent, effect) =>
                    OnboardingCardPreviewFrame(
                  draft: draft.copyWith(
                    backgroundColor: bg,
                    accentColor: accent,
                    cardEffect: effect,
                    clearBackgroundColor: bg == null,
                    clearAccentColor: accent == null,
                  ),
                ),
                onBackgroundColorChanged: (hex) {
                  _applyDraft(
                    context,
                    hex == null
                        ? draft.copyWith(clearBackgroundColor: true)
                        : draft.copyWith(backgroundColor: hex),
                  );
                },
                onAccentColorChanged: (hex) {
                  _applyDraft(
                    context,
                    hex == null
                        ? draft.copyWith(clearAccentColor: true)
                        : draft.copyWith(accentColor: hex),
                  );
                },
                onEffectChanged: (effect) {
                  _applyDraft(context, draft.copyWith(cardEffect: effect));
                },
                onLastUsedPaletteBackgroundChanged: (hex) {
                  _applyDraft(
                    context,
                    draft.copyWith(
                      backgroundColor: hex,
                      lastUsedPaletteBackgroundColor: hex,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        CardEffectCustomizeSection(
          selectedEffect: draft.cardEffect,
          onEffectChanged: (effect) {
            _applyDraft(context, draft.copyWith(cardEffect: effect));
          },
          onUpgradeToPro: upgradeWalletPlan,
          compact: true,
          headerPadding: const EdgeInsets.symmetric(horizontal: _horizontalInset),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
