import 'package:flutter/material.dart';

import '../../../../core/l10n/l10n_extensions.dart';
import '../../../../core/widgets/molecules/auth_or_divider.dart';
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 20),
        AuthOrDivider(label: context.l10n.authOrDivider),
        const SizedBox(height: 20),
        LinkedInSignInButton(
          isLoading: isLoading,
          onPressed: onLinkedInPressed,
        ),
      ],
    );
  }
}
