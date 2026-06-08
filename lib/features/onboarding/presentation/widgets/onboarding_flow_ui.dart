import 'package:flutter/material.dart';

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

/// Alt aksiyon çubuğu (ilerleme noktaları + birincil buton).
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
  });

  final int stepCount;
  final int currentIndex;
  final String primaryLabel;
  final VoidCallback? onPrimaryPressed;
  final bool isLoading;
  final bool enabled;
  final bool showStepIndicator;

  /// İçeriğin alt bar arkasından kayması için alt boşluk.
  static double contentBottomInset(
    BuildContext context, {
    bool showStepIndicator = true,
  }) {
    final bottomSafe = MediaQuery.paddingOf(context).bottom;
    const barPadding = 12.0 + 48.0 + 16.0;
    const indicatorBlock = 6.0 + 14.0;
    return barPadding +
        bottomSafe +
        (showStepIndicator ? indicatorBlock : 0);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    const primaryLabelStyle = TextStyle(
      fontWeight: FontWeight.w700,
      fontSize: 17,
      letterSpacing: 0.1,
    );

    return SafeArea(
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
                    (i) => AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: currentIndex == i ? 18 : 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: currentIndex == i
                            ? colorScheme.primary
                            : colorScheme.onSurface.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
              ],
              CustomButton(
                label: primaryLabel,
                labelStyle: primaryLabelStyle,
                onPressed: onPrimaryPressed,
                enabled: enabled,
                isLoading: isLoading,
              ),
            ],
          ),
        ),
    );
  }
}

/// Adım başlığı; isteğe bağlı kısa alt metin.
class OnboardingStepIntro extends StatelessWidget {
  const OnboardingStepIntro({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
  });

  final String title;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final hasSubtitle = subtitle != null && subtitle!.trim().isNotEmpty;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  height: 1.2,
                ),
              ),
              if (hasSubtitle) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle!,
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    height: 1.35,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}
