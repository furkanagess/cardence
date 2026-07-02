import 'package:flutter/material.dart';

import '../../l10n/app_l10n.dart';
import '../../l10n/l10n_extensions.dart';
import '../../theme/app_colors.dart';
import '../atoms/custom_button.dart';

/// Tek butonlu hata bilgilendirme diyaloğu.
class CardenceErrorDialog extends StatelessWidget {
  const CardenceErrorDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmLabel,
  });

  final String title;
  final String message;
  final String? confirmLabel;

  static Future<void> show(
    BuildContext context, {
    required String title,
    required String message,
    String? confirmLabel,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => CardenceErrorDialog(
        title: title,
        message: message,
        confirmLabel: confirmLabel,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
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
                  color: AppColors.error.withValues(alpha: isDark ? 0.2 : 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const SizedBox(
                  width: 56,
                  height: 56,
                  child: Icon(
                    Icons.error_outline_rounded,
                    size: 28,
                    color: AppColors.error,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color:
                    isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              message,
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
                backgroundColor: AppColors.error,
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
