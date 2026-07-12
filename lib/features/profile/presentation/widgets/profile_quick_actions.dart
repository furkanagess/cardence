import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Profil sekmesi: kart düzenleme kısayolları.
class ProfileQuickActions extends StatelessWidget {
  const ProfileQuickActions({
    super.key,
    this.limitHint,
    this.cardLayoutLabel,
    this.onCardLayout,
    this.networkGraphLabel,
    this.onNetworkGraph,
  });

  final String? limitHint;
  final String? cardLayoutLabel;
  final VoidCallback? onCardLayout;
  final String? networkGraphLabel;
  final VoidCallback? onNetworkGraph;

  bool get _hasTools =>
      onCardLayout != null &&
      onNetworkGraph != null &&
      cardLayoutLabel != null &&
      networkGraphLabel != null;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_hasTools) ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _ProfileShortcutCard(
                  icon: Icons.palette_outlined,
                  label: cardLayoutLabel!,
                  onTap: onCardLayout!,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ProfileShortcutCard(
                  icon: Icons.hub_outlined,
                  label: networkGraphLabel!,
                  onTap: onNetworkGraph!,
                ),
              ),
            ],
          ),
        ],
        if (limitHint != null) ...[
          const SizedBox(height: 10),
          _ProfileLimitHint(message: limitHint!),
        ],
      ],
    );
  }
}

class _ProfileShortcutCard extends StatelessWidget {
  const _ProfileShortcutCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          height: 104,
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : colorScheme.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isDark
                  ? AppColors.outlineDark.withValues(alpha: 0.4)
                  : AppColors.outlineVariant.withValues(alpha: 0.85),
            ),
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow.withValues(alpha: isDark ? 0.14 : 0.04),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 12, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: isDark ? 0.18 : 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: SizedBox(
                    width: 40,
                    height: 40,
                    child: Icon(icon, size: 22, color: AppColors.primary),
                  ),
                ),
                const Spacer(),
                Text(
                  label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    height: 1.2,
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

class _ProfileLimitHint extends StatelessWidget {
  const _ProfileLimitHint({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.warning.withValues(alpha: 0.28),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            const Icon(
              Icons.info_outline_rounded,
              size: 18,
              color: AppColors.warning,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      height: 1.35,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
