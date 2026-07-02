import 'package:flutter/material.dart';

import '../../../../core/l10n/l10n_extensions.dart';
import '../../../../core/widgets/molecules/flow_step_indicator.dart';
import '../../../onboarding/presentation/widgets/onboarding_flow_ui.dart';
import '../helpers/create_event_group_step_meta.dart';

/// Etkinlik grubu oluşturma ekranının üst adım başlığı.
class CreateEventGroupStepHeader extends StatelessWidget {
  const CreateEventGroupStepHeader({
    super.key,
    required this.currentIndex,
  });

  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = context.l10n;

    final title = CreateEventGroupStepMeta.title(l10n, currentIndex);
    final subtitle = CreateEventGroupStepMeta.subtitle(l10n, currentIndex);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FlowNumberedStepProgress(
            stepCount: CreateEventGroupStepMeta.stepCount,
            currentIndex: currentIndex,
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              l10n.eventCreateStepProgress(
                currentIndex + 1,
                CreateEventGroupStepMeta.stepCount,
              ),
              style: theme.textTheme.labelSmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 88,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ),
                    if (CreateEventGroupStepMeta.showsOptionalBadge(currentIndex))
                      const OnboardingOptionalBadge(),
                  ],
                ),
                const SizedBox(height: 6),
                Expanded(
                  child: Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
