import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/l10n/l10n_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../helpers/network_graph_canvas_theme.dart';

/// Grafik alanının sol üstünde düğüm türlerini açıklayan kompakt legend.
class NetworkGraphCanvasLegend extends StatelessWidget {
  const NetworkGraphCanvasLegend({super.key});

  @override
  Widget build(BuildContext context) {
    final brightness = NetworkGraphCanvasTheme.brightnessOf(context);
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _LegendChip(
          brightness: brightness,
          label: l10n.networkGraphLegendMe,
          shape: _LegendShape.ownCard,
        ),
        const SizedBox(height: 6),
        _LegendChip(
          brightness: brightness,
          label: l10n.networkGraphLegendConnection,
          shape: _LegendShape.connection,
        ),
        const SizedBox(height: 6),
        _LegendChip(
          brightness: brightness,
          label: l10n.nodeTypeCompany,
          shape: _LegendShape.company,
        ),
        const SizedBox(height: 6),
        _LegendChip(
          brightness: brightness,
          label: l10n.nodeTypeEvent,
          shape: _LegendShape.event,
        ),
      ],
    );
  }
}

enum _LegendShape { ownCard, connection, company, event }

class _LegendChip extends StatelessWidget {
  const _LegendChip({
    required this.brightness,
    required this.label,
    required this.shape,
  });

  final Brightness brightness;
  final String label;
  final _LegendShape shape;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isDark = brightness == Brightness.dark;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.graphNodeLabelBackgroundFor(brightness),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: AppColors.graphNodeLabelBorderFor(brightness),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _LegendShapeIcon(shape: shape, isDark: isDark),
            const SizedBox(width: 8),
            Text(
              label,
              style: textTheme.labelMedium?.copyWith(
                color: AppColors.graphCanvasPrimaryTextFor(brightness),
                fontWeight: FontWeight.w700,
                letterSpacing: 0.1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LegendShapeIcon extends StatelessWidget {
  const _LegendShapeIcon({
    required this.shape,
    required this.isDark,
  });

  final _LegendShape shape;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    switch (shape) {
      case _LegendShape.ownCard:
        return Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.graphOwnCardAccent,
              width: 2,
            ),
          ),
        );
      case _LegendShape.connection:
        return Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isDark ? AppColors.surfaceDark : AppColors.graphEdgeNeutral,
            border: Border.all(
              color: isDark
                  ? AppColors.outlineDark
                  : AppColors.outlineVariant,
            ),
          ),
        );
      case _LegendShape.company:
        return Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.graphCompanyNodeDark
                : AppColors.graphCompanyNodeLight,
            borderRadius: BorderRadius.circular(3),
            border: Border.all(
              color: isDark ? AppColors.outlineDark : AppColors.outline,
            ),
          ),
        );
      case _LegendShape.event:
        return Transform.rotate(
          angle: math.pi / 4,
          child: Container(
            width: 11,
            height: 11,
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.graphEventNodeDark
                  : AppColors.graphEventNodeLight,
              borderRadius: BorderRadius.circular(2),
              border: Border.all(color: AppColors.graphEventAccent, width: 1.2),
            ),
          ),
        );
    }
  }
}
