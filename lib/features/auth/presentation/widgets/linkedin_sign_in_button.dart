import 'package:flutter/material.dart';

import '../../../../core/l10n/l10n_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/atoms/linked_in_brand_icon.dart';

/// LinkedIn ile giriş — marka uyumlu, outline sosyal buton.
class LinkedInSignInButton extends StatelessWidget {
  const LinkedInSignInButton({
    super.key,
    required this.onPressed,
    this.isLoading = false,
    this.label,
  });

  final VoidCallback? onPressed;
  final bool isLoading;
  final String? label;

  static const double _height = 48;
  static const double _radius = 10;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isInteractive = !isLoading && onPressed != null;
    final resolvedLabel = label ?? context.l10n.linkedinIleDevamEt;

    final backgroundColor =
        isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final borderColor = isDark ? AppColors.outlineDark : AppColors.outline;
    final textColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;

    return SizedBox(
      width: double.infinity,
      height: _height,
      child: Material(
        color: backgroundColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_radius),
          side: BorderSide(
            color: isInteractive
                ? borderColor
                : borderColor.withValues(alpha: 0.55),
          ),
        ),
        child: InkWell(
          onTap: isInteractive ? onPressed : null,
          borderRadius: BorderRadius.circular(_radius),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: isLoading
                ? Center(
                    child: SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.linkedInBrand,
                      ),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const LinkedInBrandIcon(size: 22),
                      const SizedBox(width: 12),
                      Flexible(
                        child: Text(
                          resolvedLabel,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: textColor,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.1,
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
