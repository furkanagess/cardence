import 'package:flutter/material.dart';
import '../../l10n/app_l10n.dart';
import '../../l10n/l10n_extensions.dart';

import '../../theme/app_colors.dart';
import '../atoms/custom_button.dart';

/// Başarılı premium satın alımı veya geri yükleme sonrası bilgilendirme diyalogu.
class PurchaseSuccessDialog extends StatelessWidget {
  const PurchaseSuccessDialog({
    super.key,
    this.title,
    this.message,
    this.confirmLabel,
  });

  final String? title;
  final String? message;
  final String? confirmLabel;

  static Future<void> show(
    BuildContext context, {
    String? title,
    String? message,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (context) => PurchaseSuccessDialog(
        title: title,
        message: message,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final resolvedTitle = title ?? AppL10n.purchaseSuccessful(context.l10n);
    final resolvedMessage =
        message ?? AppL10n.premiumWalletActivatedMessage(context.l10n);
    final resolvedConfirm = confirmLabel ?? AppL10n.tamam(context.l10n);

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 28),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isDark ? AppColors.outlineDark : AppColors.outlineVariant,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: isDark ? 0.2 : 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const SizedBox(
                  width: 56,
                  height: 56,
                  child: Icon(
                    Icons.check_circle_outline_rounded,
                    size: 28,
                    color: AppColors.success,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              resolvedTitle,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color:
                    isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              resolvedMessage,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 28),
            CustomButton(
              label: resolvedConfirm,
              onPressed: () => Navigator.of(context).pop(),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.success,
                foregroundColor: AppColors.textOnPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
