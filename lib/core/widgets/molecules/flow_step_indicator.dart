import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

/// Çok adımlı akışlarda üst makro ilerleme göstergesi (daire + etiket).
class FlowStepIndicatorDot extends StatelessWidget {
  const FlowStepIndicatorDot({
    super.key,
    required this.label,
    required this.title,
    required this.active,
    required this.completed,
  });

  final String label;
  final String title;
  final bool active;
  final bool completed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final highlighted = active || completed;
    final circleColor = highlighted
        ? colorScheme.primary
        : (isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariant);
    final contentColor =
        highlighted ? colorScheme.onPrimary : colorScheme.onSurfaceVariant;
    final titleColor =
        highlighted ? colorScheme.primary : colorScheme.onSurfaceVariant;

    return SizedBox(
      width: 56,
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: circleColor,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: completed
                ? Icon(Icons.check_rounded, size: 16, color: contentColor)
                : Text(
                    label,
                    style: textTheme.labelLarge?.copyWith(
                      color: contentColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            textAlign: TextAlign.center,
            style: textTheme.labelSmall?.copyWith(
              color: titleColor,
              fontWeight: highlighted ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

/// Yatay numaralı adım ilerlemesi (1 · 2 · 3 · …).
class FlowNumberedStepProgress extends StatelessWidget {
  const FlowNumberedStepProgress({
    super.key,
    required this.stepCount,
    required this.currentIndex,
  });

  final int stepCount;
  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    if (stepCount <= 0) return const SizedBox.shrink();

    final children = <Widget>[];
    for (var index = 0; index < stepCount; index++) {
      if (index > 0) {
        children.add(
          FlowStepConnectorLine(highlighted: index <= currentIndex),
        );
      }
      children.add(
        _FlowNumberedStepDot(
          number: index + 1,
          active: index == currentIndex,
          completed: index < currentIndex,
        ),
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: children,
    );
  }
}

class _FlowNumberedStepDot extends StatelessWidget {
  const _FlowNumberedStepDot({
    required this.number,
    required this.active,
    required this.completed,
  });

  final int number;
  final bool active;
  final bool completed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final highlighted = active || completed;
    final circleColor = highlighted
        ? colorScheme.primary
        : (isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariant);
    final contentColor =
        highlighted ? colorScheme.onPrimary : colorScheme.onSurfaceVariant;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: circleColor,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: completed
          ? Icon(Icons.check_rounded, size: 16, color: contentColor)
          : Text(
              '$number',
              style: textTheme.labelLarge?.copyWith(
                color: contentColor,
                fontWeight: FontWeight.w700,
              ),
            ),
    );
  }
}

/// İki makro adım göstergesi arasındaki bağlantı çizgisi.
class FlowStepConnectorLine extends StatelessWidget {
  const FlowStepConnectorLine({super.key, required this.highlighted});

  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: highlighted
                ? colorScheme.primary
                : (isDark
                    ? AppColors.outlineDark.withValues(alpha: 0.45)
                    : AppColors.outlineVariant),
            borderRadius: BorderRadius.circular(999),
          ),
          child: const SizedBox(height: 2),
        ),
      ),
    );
  }
}
