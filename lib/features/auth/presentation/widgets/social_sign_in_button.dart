import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Ortak sosyal giriş butonu — tüm sağlayıcılar için aynı boyut/stil
/// (App Store Sign in with Apple eşdeğerlik kuralı).
class SocialSignInButton extends StatelessWidget {
  const SocialSignInButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
    this.isLoading = false,
    this.loadingColor,
  });

  final String label;
  final Widget icon;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Color? loadingColor;

  static const double height = 48;
  static const double radius = 10;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isInteractive = !isLoading && onPressed != null;

    final backgroundColor =
        isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final borderColor = isDark ? AppColors.outlineDark : AppColors.outline;
    final textColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;

    return SizedBox(
      width: double.infinity,
      height: height,
      child: Material(
        color: backgroundColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
          side: BorderSide(
            color: isInteractive
                ? borderColor
                : borderColor.withValues(alpha: 0.55),
          ),
        ),
        child: InkWell(
          onTap: isInteractive ? onPressed : null,
          borderRadius: BorderRadius.circular(radius),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: isLoading
                ? Center(
                    child: SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: loadingColor ?? theme.colorScheme.primary,
                      ),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(width: 22, height: 22, child: icon),
                      const SizedBox(width: 12),
                      Flexible(
                        child: Text(
                          label,
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
