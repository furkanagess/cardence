import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

/// Yeni kart oluşturma aksiyonu (profil / boş slot alanı).
class CreateCardButton extends StatelessWidget {
  const CreateCardButton({
    super.key,
    required this.label,
    required this.onTap,
  });

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          height: 54,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.28),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                DecoratedBox(
                  decoration: const BoxDecoration(
                    color: AppColors.textOnPrimary,
                    shape: BoxShape.circle,
                  ),
                  child: SizedBox(
                    width: 28,
                    height: 28,
                    child: Icon(
                      Icons.add_rounded,
                      size: 20,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.titleSmall?.copyWith(
                      color: AppColors.textOnPrimary,
                      fontWeight: FontWeight.w700,
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
