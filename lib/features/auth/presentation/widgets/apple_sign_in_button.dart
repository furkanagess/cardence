import 'package:flutter/material.dart';

import '../../../../core/l10n/l10n_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/atoms/apple_brand_icon.dart';
import 'social_sign_in_button.dart';

/// Apple ile giriş — diğer sosyal butonlarla eşdeğer stil (Guideline 4).
class AppleSignInButton extends StatelessWidget {
  const AppleSignInButton({
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
      label: label ?? context.l10n.appleIleDevamEt,
      icon: const AppleBrandIcon(size: 24),
      onPressed: onPressed,
      isLoading: isLoading,
      loadingColor: AppColors.appleBrand,
      iconOnly: iconOnly,
    );
  }
}
