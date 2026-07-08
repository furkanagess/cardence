import 'package:flutter/material.dart';

import '../../../../core/l10n/l10n_extensions.dart';
import '../../../../core/widgets/molecules/flow_step_indicator.dart';
import '../../../onboarding/presentation/widgets/onboarding_flow_ui.dart';
import '../helpers/create_event_group_step_meta.dart';

/// Etkinlik oluşturma akışının üstündeki sabit adım ilerleme çubuğu.
class CreateEventGroupStepProgress extends StatelessWidget {
  const CreateEventGroupStepProgress({
    super.key,
    required this.currentIndex,
  });

  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
      child: FlowNumberedStepProgress(
        stepCount: CreateEventGroupStepMeta.stepCount,
        currentIndex: currentIndex,
      ),
    );
  }
}

/// Kaydırılabilir adım başlığı ve alt başlığı.
class CreateEventGroupStepTitleHeader extends StatelessWidget {
  const CreateEventGroupStepTitleHeader({
    super.key,
    required this.currentIndex,
    this.compact = false,
  });

  final int currentIndex;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = context.l10n;

    final title = CreateEventGroupStepMeta.title(l10n, currentIndex);
    final subtitle = CreateEventGroupStepMeta.subtitle(l10n, currentIndex);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: compact
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
                if (subtitle.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      height: 1.35,
                    ),
                  ),
                ],
              ],
            )
          : SizedBox(
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
                      if (CreateEventGroupStepMeta.showsOptionalBadge(
                        currentIndex,
                      ))
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
    );
  }
}
