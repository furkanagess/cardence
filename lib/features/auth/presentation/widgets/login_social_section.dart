import 'package:flutter/material.dart';

import 'linkedin_sign_in_button.dart';

class LoginSocialSection extends StatelessWidget {
  const LoginSocialSection({
    super.key,
    required this.isLoading,
    required this.onLinkedInPressed,
  });

  final bool isLoading;
  final VoidCallback? onLinkedInPressed;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final dividerColor = Theme.of(context).colorScheme.outlineVariant;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(child: Divider(color: dividerColor, height: 1)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Text(
                'veya',
                style: textTheme.labelMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.2,
                ),
              ),
            ),
            Expanded(child: Divider(color: dividerColor, height: 1)),
          ],
        ),
        const SizedBox(height: 20),
        LinkedInSignInButton(
          isLoading: isLoading,
          onPressed: onLinkedInPressed,
        ),
      ],
    );
  }
}
