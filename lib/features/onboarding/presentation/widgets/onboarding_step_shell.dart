import 'package:flutter/material.dart';

import 'onboarding_flow_ui.dart';

/// Onboarding adımlarında ortak başlık ve form alanı düzeni.
class OnboardingStepShell extends StatelessWidget {
  const OnboardingStepShell({
    super.key,
    required this.title,
    required this.child,
    this.subtitle,
    this.optionalHint,
  });

  final String title;
  final String? subtitle;
  final Widget child;
  final String? optionalHint;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          OnboardingStepIntro(
            title: title,
            subtitle: subtitle,
            trailing: optionalHint == null
                ? null
                : Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      optionalHint!,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
          ),
          const SizedBox(height: 16),
          child,
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
