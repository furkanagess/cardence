import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/l10n/l10n_extensions.dart';
import '../../../../core/widgets/atoms/custom_button.dart';

class NetworkGraphEmptyState extends StatelessWidget {
  const NetworkGraphEmptyState({
    super.key,
    required this.onRefresh,
  });

  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.hub_outlined,
              size: 56,
              color: colorScheme.primary.withValues(alpha: 0.75),
            ),
            const SizedBox(height: 16),
            Text(
              context.l10n.networkGraphNotYetCreated,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimaryDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              context.l10n.networkGraphEmptySubtitle,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondaryDark,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 20),
            CustomButton.tonal(
              label: context.l10n.refresh,
              icon: Icons.refresh_rounded,
              onPressed: onRefresh,
              fullWidth: false,
            ),
          ],
        ),
      ),
    );
  }
}
