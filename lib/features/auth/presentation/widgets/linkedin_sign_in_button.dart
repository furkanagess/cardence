import 'package:flutter/material.dart';

import '../../../../core/l10n/l10n_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/atoms/linked_in_brand_icon.dart';
import 'social_sign_in_button.dart';

/// LinkedIn ile giriş — ortak sosyal buton stili.
class LinkedInSignInButton extends StatelessWidget {
  const LinkedInSignInButton({
    super.key,
    required this.onPressed,
    this.isLoading = false,
    this.label,
    this.iconOnly = true,
  });

  final VoidCallback? onPressed;
  final bool isLoading;
  final String? label;
  final bool iconOnly;

  @override
  Widget build(BuildContext context) {
    return SocialSignInButton(
      label: label ?? context.l10n.linkedinIleDevamEt,
      icon: const LinkedInBrandIcon(size: 24),
      onPressed: onPressed,
      isLoading: isLoading,
      loadingColor: AppColors.linkedInBrand,
      iconOnly: iconOnly,
    );
  }
}
