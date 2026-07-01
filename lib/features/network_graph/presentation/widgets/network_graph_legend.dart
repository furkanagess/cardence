import 'package:flutter/material.dart';

import '../../../../core/l10n/app_l10n.dart';
import '../../../../core/l10n/l10n_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/graph_node_type.dart';
import 'network_graph_node_list.dart';

class NetworkGraphLegend extends StatelessWidget {
  const NetworkGraphLegend({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    const nodeTypes = [
      GraphNodeType.card,
      GraphNodeType.company,
      GraphNodeType.event,
    ];

    final edgeLegend = [
      _EdgeLegendItem(
          color: AppColors.graphEdgeSaved,
          label: AppL10n.edgeTypeSaved(context.l10n)),
      _EdgeLegendItem(
          color: AppColors.graphEdgeSavedBy,
          label: AppL10n.edgeTypeSavedBy(context.l10n)),
      _EdgeLegendItem(
          color: AppColors.graphEdgeEvent,
          label: AppL10n.edgeTypeEventLink(context.l10n)),
      _EdgeLegendItem(
          color: AppColors.graphEdgeOwns,
          label: AppL10n.edgeTypeOwns(context.l10n)),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 12,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const _NodeLegendShape(
                  type: GraphNodeType.card,
                  isOwnCard: true,
                ),
                const SizedBox(width: 6),
                Text(
                  context.l10n.kendiKartlarm,
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            ...nodeTypes.map((type) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _NodeLegendShape(type: type),
                  const SizedBox(width: 6),
                  Text(
                    NetworkGraphNodeLabel.labelFor(context.l10n, type),
                    style: theme.textTheme.labelSmall,
                  ),
                ],
              );
            }),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 8,
          children: edgeLegend,
        ),
      ],
    );
  }
}

class _NodeLegendShape extends StatelessWidget {
  const _NodeLegendShape({
    required this.type,
    this.isOwnCard = false,
  });

  final GraphNodeType type;
  final bool isOwnCard;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final Color background;
    final Color border;
    final Color foreground;
    final IconData icon;

    if (isOwnCard) {
      background = isDark ? AppColors.primaryContainerDark : AppColors.primaryContainer;
      foreground = isDark ? AppColors.onPrimaryContainerDark : AppColors.onPrimaryContainer;
      border = Colors.amber;
      icon = Icons.person_pin_rounded;
    } else {
      icon = NetworkGraphNodeIcon.iconFor(type);
      switch (type) {
        case GraphNodeType.user:
          background = isDark ? AppColors.surfaceVariantDark : AppColors.primaryContainer;
          foreground = isDark ? AppColors.textPrimaryDark : AppColors.onPrimaryContainer;
          border = isDark ? AppColors.outlineDark : AppColors.outlineVariant;
          break;
        case GraphNodeType.card:
          background = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
          foreground = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
          border = isDark ? AppColors.primaryDarkTheme : AppColors.primaryLight;
          break;
        case GraphNodeType.company:
          background = isDark ? AppColors.graphCompanyNodeDark : AppColors.graphCompanyNodeLight;
          foreground = isDark ? AppColors.textPrimaryDark : AppColors.secondary;
          border = isDark ? AppColors.outlineDark : AppColors.outline;
          break;
        case GraphNodeType.event:
          background = isDark ? AppColors.graphEventNodeDark : AppColors.graphEventNodeLight;
          foreground = AppColors.graphEventAccent;
          border = AppColors.graphEventAccent;
          break;
        default:
          background = isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariant;
          foreground = isDark ? AppColors.textPrimaryDark : AppColors.textSecondary;
          border = isDark ? AppColors.outlineDark : AppColors.outlineVariant;
      }
    }

    final isCompany = type == GraphNodeType.company || type == GraphNodeType.organization;
    final isEvent = type == GraphNodeType.event || type == GraphNodeType.organizationEvent;

    Widget shapeWidget;
    if (isEvent && !isOwnCard) {
      shapeWidget = Transform.rotate(
        angle: 3.14159 / 4,
        child: Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: background,
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(2),
            border: Border.all(color: border, width: 1),
          ),
          child: Transform.rotate(
            angle: -3.14159 / 4,
            child: Icon(
              icon,
              color: foreground,
              size: 8,
            ),
          ),
        ),
      );
    } else if (isCompany) {
      shapeWidget = Container(
        width: 16,
        height: 16,
        decoration: BoxDecoration(
          color: background,
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: border, width: 1),
        ),
        child: Icon(
          icon,
          color: foreground,
          size: 9,
        ),
      );
    } else {
      shapeWidget = Container(
        width: 16,
        height: 16,
        decoration: BoxDecoration(
          color: background,
          shape: BoxShape.circle,
          border: Border.all(color: border, width: 1.2),
        ),
        child: Icon(
          icon,
          color: foreground,
          size: 9,
        ),
      );
    }

    return shapeWidget;
  }
}

class _EdgeLegendItem extends StatelessWidget {
  const _EdgeLegendItem({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 18,
          height: 4,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall,
        ),
      ],
    );
  }
}
