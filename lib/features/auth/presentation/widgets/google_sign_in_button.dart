import 'package:flutter/material.dart';

import '../../../../core/l10n/l10n_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/atoms/google_brand_icon.dart';
import 'social_sign_in_button.dart';

/// Google ile giriş — LinkedIn/Apple ile eşdeğer stil.
class GoogleSignInButton extends StatelessWidget {
  const GoogleSignInButton({
    super.key,
    required this.onPressed,
    this.isLoading = false,
    this.label,
  });

  final VoidCallback? onPressed;
  final bool isLoading;
  final String? label;

  @override
  Widget build(BuildContext context) {
    return SocialSignInButton(
      label: label ?? context.l10n.googleIleDevamEt,
      icon: const GoogleBrandIcon(size: 22),
      onPressed: onPressed,
      isLoading: isLoading,
      loadingColor: AppColors.googleBlue,
    );
  }
}
