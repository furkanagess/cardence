import 'package:flutter/material.dart';

import '../../../../core/l10n/l10n_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/atoms/custom_button.dart';

/// Gizlilik politikası alt çubuğundaki hesap silme aksiyonu.
class PrivacyPolicyDeleteAccountBar extends StatelessWidget {
  const PrivacyPolicyDeleteAccountBar({
    super.key,
    required this.isLoading,
    required this.onDeleteAccount,
  });

  final bool isLoading;
  final VoidCallback onDeleteAccount;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        border: Border(
          top: BorderSide(
            color: isDark
                ? AppColors.outlineDark.withValues(alpha: 0.4)
                : AppColors.outlineVariant.withValues(alpha: 0.9),
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 14),
          child: CustomButton(
            label: context.l10n.deleteAccountTitle,
            icon: Icons.delete_forever_rounded,
            enabled: !isLoading,
            isLoading: isLoading,
            onPressed: isLoading ? null : onDeleteAccount,
            height: 52,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.textOnPrimary,
              disabledBackgroundColor: AppColors.error.withValues(alpha: 0.45),
              disabledForegroundColor:
                  AppColors.textOnPrimary.withValues(alpha: 0.75),
              elevation: 0,
              shadowColor: Colors.transparent,
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
