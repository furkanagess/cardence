import 'package:flutter/material.dart';
import '../../../../core/l10n/l10n_extensions.dart';

import '../../../../core/widgets/atoms/custom_button.dart';

/// Üst ilerleme çubuğu ve adım etiketi.
class OnboardingProgressHeader extends StatelessWidget {
  const OnboardingProgressHeader({
    super.key,
    required this.stepIndex,
    required this.stepCount,
    required this.stepLabel,
  });

  final int stepIndex;
  final int stepCount;
  final String stepLabel;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final progress = stepCount <= 0 ? 0.0 : stepIndex / stepCount;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text(
                stepLabel,
                style: textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.primary,
                ),
              ),
              const Spacer(),
              Text(
                '$stepIndex / $stepCount',
                style: textTheme.labelMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 4,
              backgroundColor: colorScheme.surfaceContainerHighest,
              color: colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}

/// İsteğe bağlı adım rozeti.
class OnboardingOptionalBadge extends StatelessWidget {
  const OnboardingOptionalBadge({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        context.l10n.opsiyonel,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}

/// Alt aksiyon çubuğu (ilerleme noktaları + geri / birincil buton).
class OnboardingBottomBar extends StatelessWidget {
  const OnboardingBottomBar({
    super.key,
    required this.stepCount,
    required this.currentIndex,
    required this.primaryLabel,
    required this.onPrimaryPressed,
    this.isLoading = false,
    this.enabled = true,
    this.showStepIndicator = true,
    this.onStepSelected,
    this.onBackPressed,
    this.backLabel,
  });

  final int stepCount;
  final int currentIndex;
  final String primaryLabel;
  final VoidCallback? onPrimaryPressed;
  final bool isLoading;
  final bool enabled;
  final bool showStepIndicator;
  final ValueChanged<int>? onStepSelected;
  final VoidCallback? onBackPressed;
  final String? backLabel;

  /// İçeriğin alt bar arkasından kayması için alt boşluk.
  static double contentBottomInset(
    BuildContext context, {
    bool showStepIndicator = true,
  }) {
    final bottomSafe = MediaQuery.paddingOf(context).bottom;
    const barPadding = 12.0 + 48.0 + 16.0;
    const indicatorBlock = 6.0 + 14.0;
    return barPadding + bottomSafe + (showStepIndicator ? indicatorBlock : 0);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    const actionButtonHeight = 48.0;
    const actionLabelStyle = TextStyle(
      fontWeight: FontWeight.w700,
      fontSize: 17,
      letterSpacing: 0.1,
      height: 1,
    );

    return Material(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (showStepIndicator) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    stepCount,
                    (i) {
                      final isActive = currentIndex == i;
                      final canNavigateBack =
                          onStepSelected != null && i < currentIndex;

                      return GestureDetector(
                        onTap:
                            canNavigateBack ? () => onStepSelected!(i) : null,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          width: isActive ? 18 : 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: isActive
                                ? colorScheme.primary
                                : colorScheme.onSurface.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 14),
              ],
              if (onBackPressed != null && backLabel != null)
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: CustomButton.outlined(
                        label: backLabel!,
                        labelStyle: actionLabelStyle,
                        height: actionButtonHeight,
                        onPressed: isLoading ? null : onBackPressed,
                        enabled: !isLoading,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 3,
                      child: CustomButton(
                        label: primaryLabel,
                        labelStyle: actionLabelStyle,
                        height: actionButtonHeight,
                        onPressed: onPrimaryPressed,
                        enabled: enabled,
                        isLoading: isLoading,
                      ),
                    ),
                  ],
                )
              else
                CustomButton(
                  label: primaryLabel,
                  labelStyle: actionLabelStyle,
                  height: actionButtonHeight,
                  onPressed: onPrimaryPressed,
                  enabled: enabled,
                  isLoading: isLoading,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
