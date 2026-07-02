import 'package:flutter/material.dart';

/// Onboarding adımlarında ortak form alanı düzeni.
class OnboardingStepShell extends StatelessWidget {
  const OnboardingStepShell({
    super.key,
    required this.child,
    this.subtitle,
  });

  final String? subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final hasSubtitle = subtitle != null && subtitle!.trim().isNotEmpty;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (hasSubtitle) ...[
            Text(
              subtitle!,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 16),
          ],
          Align(
            alignment: Alignment.topCenter,
            child: child,
          ),
        ],
      ),
    );
  }
}

/// Form alanı etiketi; zorunlu alanlarda yıldız gösterir.
class OnboardingFieldLabel extends StatelessWidget {
  const OnboardingFieldLabel({
    super.key,
    required this.label,
    this.required = false,
  });

  final String label;
  final bool required;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text.rich(
        TextSpan(
          text: label,
          style: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          children: [
            if (required)
              TextSpan(
                text: ' *',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
          ],
        ),
      ),
    );
  }
}
