import 'package:flutter/material.dart';
import '../../../../core/l10n/l10n_extensions.dart';
import '../../../../core/widgets/molecules/flow_step_indicator.dart';

import '../cubit/onboarding_state.dart';
import '../onboarding_step_meta.dart';
import '../onboarding_step_titles.dart';
import 'onboarding_flow_ui.dart';

/// Onboarding sayfalarının üstündeki adım adım ilerleme başlığı.
class OnboardingStepHeader extends StatelessWidget {
  const OnboardingStepHeader({
    super.key,
    required this.currentIndex,
  });

  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = context.l10n;

    final title = OnboardingStepMeta.title(l10n, currentIndex);
    final subtitle = OnboardingStepMeta.subtitle(l10n, currentIndex);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FlowNumberedStepProgress(
            stepCount: OnboardingState.stepCount,
            currentIndex: currentIndex,
          ),
          const SizedBox(height: 18),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
              if (OnboardingStepTitles.showsOptionalBadge(currentIndex))
                const OnboardingOptionalBadge(),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}
