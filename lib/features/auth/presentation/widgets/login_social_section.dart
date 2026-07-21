import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../../core/l10n/l10n_extensions.dart';
import '../../../../core/widgets/molecules/auth_or_divider.dart';
import 'apple_sign_in_button.dart';
import 'google_sign_in_button.dart';
import 'linkedin_sign_in_button.dart';

class LoginSocialSection extends StatelessWidget {
  const LoginSocialSection({
    super.key,
    required this.isLoading,
    required this.onApplePressed,
    required this.onGooglePressed,
    required this.onLinkedInPressed,
  });

  final bool isLoading;
  final VoidCallback? onApplePressed;
  final VoidCallback? onGooglePressed;
  final VoidCallback? onLinkedInPressed;

  bool get _showApple {
    if (kIsWeb) return false;
    return Platform.isIOS || Platform.isMacOS;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 20),
        AuthOrDivider(label: context.l10n.authOrDivider),
        const SizedBox(height: 20),
        if (_showApple) ...[
          AppleSignInButton(
            isLoading: isLoading,
            onPressed: onApplePressed,
          ),
          const SizedBox(height: 12),
        ],
        GoogleSignInButton(
          isLoading: isLoading,
          onPressed: onGooglePressed,
        ),
        const SizedBox(height: 12),
        LinkedInSignInButton(
          isLoading: isLoading,
          onPressed: onLinkedInPressed,
        ),
      ],
    );
  }
}
