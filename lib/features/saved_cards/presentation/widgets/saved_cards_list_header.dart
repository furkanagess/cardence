import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Liste modunda kart sayısı başlığı.
class SavedCardsListHeader extends StatelessWidget {
  const SavedCardsListHeader({
    super.key,
    required this.count,
  });

  final int count;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 4, 4, 12),
      child: Text(
        count == 1 ? '1 kart' : '$count kart',
        style: textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w700,
          color: Theme.of(context).brightness == Brightness.dark
              ? AppColors.textPrimaryDark
              : AppColors.textPrimary,
        ),
      ),
    );
  }
}
