import 'package:flutter/material.dart';
import '../../../core/l10n/l10n_extensions.dart';

import '../../theme/app_colors.dart';
import '../atoms/custom_button.dart';
import '../../theme/splash_theme.dart';
import '../organisms/cardence_logo_merge_animation.dart';

/// Oturum süresi dolduğunda gösterilen zorunlu çıkış diyaloğu.
class SessionExpiredDialog extends StatelessWidget {
  const SessionExpiredDialog({
    super.key,
    required this.message,
    required this.onLoginPressed,
  });

  final String message;
  final Future<void> Function() onLoginPressed;

  static const double _logoSize = 152;

  static Future<void> show(
    BuildContext context, {
    required String message,
    required Future<void> Function() onLoginPressed,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      useRootNavigator: true,
      builder: (dialogContext) {
        return PopScope(
          canPop: false,
          child: SessionExpiredDialog(
            message: message,
            onLoginPressed: () async {
              Navigator.of(dialogContext).pop();
              await onLoginPressed();
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final subtitle = context.l10n.sessionExpired;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 28),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(
          color: isDark ? AppColors.outlineDark : AppColors.outlineVariant,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  colorScheme.primary.withValues(alpha: isDark ? 0.18 : 0.1),
                  colorScheme.surface.withValues(alpha: 0),
                ],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 8),
              child: CardenceLogoMergeAnimation(
                size: _logoSize,
                repeat: true,
                logoAssetPath: SplashTheme.logoAsset(
                  theme.brightness,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  context.l10n.oturumSonaErdi,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 24),
                CustomButton(
                  label: context.l10n.giriYap,
                  icon: Icons.login_rounded,
                  onPressed: onLoginPressed,
                  style: FilledButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: AppColors.textOnPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
