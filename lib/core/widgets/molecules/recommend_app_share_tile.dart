import 'package:flutter/material.dart';
import '../../../core/l10n/l10n_extensions.dart';

import '../../share/app_share.dart';
import '../../theme/app_colors.dart';

/// Uygulamayı arkadaşlarla paylaşma satırı.
class RecommendAppShareTile extends StatelessWidget {
  const RecommendAppShareTile({super.key});

  Future<void> _share(BuildContext context) async {
    Rect? shareOrigin;
    final box = context.findRenderObject() as RenderBox?;
    if (box != null && box.hasSize) {
      shareOrigin = box.localToGlobal(Offset.zero) & box.size;
    }
    await AppShare.share(sharePositionOrigin: shareOrigin);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: colorScheme.surfaceContainerLowest.withValues(
        alpha: isDark ? 0.55 : 0.85,
      ),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: () => _share(context),
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: isDark ? 0.22 : 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.ios_share_rounded,
                  size: 22,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.arkadalarnaner,
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      context.l10n.cardencePaylasBirlikteBaglanti,
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.share_rounded,
                color: colorScheme.primary,
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
