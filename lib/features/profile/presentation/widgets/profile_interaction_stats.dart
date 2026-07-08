import 'package:flutter/material.dart';
import '../../../../core/l10n/l10n_extensions.dart';

import '../../../../core/theme/app_colors.dart';

class ProfileInteractionStats extends StatelessWidget {
  const ProfileInteractionStats({
    super.key,
    required this.eventGroupCount,
    required this.totalWalletSaveCount,
  });

  final int eventGroupCount;
  final int totalWalletSaveCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final panelColor = isDark
        ? AppColors.primaryContainerDark.withValues(alpha: 0.35)
        : AppColors.primaryContainer.withValues(alpha: 0.42);
    final infoPanelColor = isDark
        ? AppColors.surfaceDark.withValues(alpha: 0.72)
        : AppColors.surfaceLight.withValues(alpha: 0.88);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: panelColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    context.l10n.sonEtkileimler.toUpperCase(),
                    style: textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                Icon(
                  Icons.analytics_outlined,
                  size: 18,
                  color: colorScheme.primary.withValues(alpha: 0.85),
                ),
              ],
            ),
            const SizedBox(height: 14),
            DecoratedBox(
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark
                      ? AppColors.outlineDark.withValues(alpha: 0.35)
                      : AppColors.outlineVariant.withValues(alpha: 0.7),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 18),
                child: IntrinsicHeight(
                  child: Row(
                    children: [
                      Expanded(
                        child: _ProfileStatColumn(
                          value: '$eventGroupCount',
                          label: context.l10n.etkinlikGrubu,
                        ),
                      ),
                      VerticalDivider(
                        width: 1,
                        thickness: 1,
                        color: isDark
                            ? AppColors.outlineDark.withValues(alpha: 0.45)
                            : AppColors.outlineVariant.withValues(alpha: 0.9),
                      ),
                      Expanded(
                        child: _ProfileStatColumn(
                          value: '$totalWalletSaveCount',
                          label: context.l10n.czdanaEklendi,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            DecoratedBox(
              decoration: BoxDecoration(
                color: infoPanelColor,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 14, 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: SizedBox(
                        width: 28,
                        height: 28,
                        child: Icon(
                          Icons.info_outline_rounded,
                          size: 16,
                          color: colorScheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: totalWalletSaveCount == 0
                          ? Text(
                              context.l10n.cardsNotYetSaved,
                              style: textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                                height: 1.4,
                              ),
                            )
                          : Text(
                              context.l10n.profileCardsSavedByOthersInfo(
                                totalWalletSaveCount,
                              ),
                              style: textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                                height: 1.4,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileStatColumn extends StatelessWidget {
  const _ProfileStatColumn({
    required this.value,
    required this.label,
  });

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        children: [
          Text(
            value,
            style: textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
              height: 1,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
