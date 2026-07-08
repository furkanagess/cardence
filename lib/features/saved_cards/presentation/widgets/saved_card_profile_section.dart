import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../helpers/saved_card_detail_theme.dart';
import '../../../../core/widgets/atoms/custom_button.dart';

/// Kart detay bölümü — tema uyumlu başlık + içerik.
class SavedCardProfileSection extends StatelessWidget {
  const SavedCardProfileSection({
    super.key,
    required this.title,
    required this.child,
    this.actionLabel,
    this.onAction,
    this.trailingIcon,
    this.titleColor,
    this.padding = const EdgeInsets.fromLTRB(20, 20, 20, 0),
  });

  final String title;
  final Widget child;
  final String? actionLabel;
  final VoidCallback? onAction;
  final IconData? trailingIcon;
  final Color? titleColor;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final textPrimary = SavedCardDetailTheme.textPrimary(context);
    final textSecondary = SavedCardDetailTheme.textSecondary(context);

    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: titleColor ?? textPrimary,
                  ),
                ),
              ),
              if (actionLabel != null && onAction != null)
                CustomButton.text(
                  label: actionLabel!,
                  onPressed: onAction,
                  height: 0,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    foregroundColor: AppColors.primary,
                  ),
                )
              else if (trailingIcon != null)
                Icon(
                  trailingIcon,
                  size: 20,
                  color: textSecondary,
                ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}
