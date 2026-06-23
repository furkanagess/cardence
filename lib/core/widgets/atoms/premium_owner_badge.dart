import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

/// Premium kart sahibi rozeti (kart köşesi veya liste satırı).
class PremiumOwnerBadge extends StatelessWidget {
  const PremiumOwnerBadge({
    super.key,
    this.size = 22,
  });

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.94),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withValues(alpha: 0.16),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Icon(
        Icons.star_rounded,
        size: size * 0.62,
        color: AppColors.textOnPrimary,
      ),
    );
  }
}
