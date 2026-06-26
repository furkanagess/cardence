import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/graph_node_type.dart';
import 'network_graph_node_list.dart';

class NetworkGraphLegend extends StatelessWidget {
  const NetworkGraphLegend({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    const nodeTypes = [
      GraphNodeType.user,
      GraphNodeType.card,
      GraphNodeType.company,
      GraphNodeType.event,
    ];

    const edgeLegend = [
      _EdgeLegendItem(color: AppColors.graphEdgeSaved, label: 'Senin kaydettiğin'),
      _EdgeLegendItem(color: AppColors.graphEdgeSavedBy, label: 'Seni kaydeden'),
      _EdgeLegendItem(color: AppColors.graphEdgeEvent, label: 'Etkinlik bağı'),
      _EdgeLegendItem(color: AppColors.graphEdgeOwns, label: 'Kart sahibi'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 12,
          runSpacing: 8,
          children: nodeTypes.map((type) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  NetworkGraphNodeIcon.iconFor(type),
                  size: 16,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 4),
                Text(
                  NetworkGraphNodeLabel.labelFor(type),
                  style: theme.textTheme.labelSmall,
                ),
              ],
            );
          }).toList(),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 12,
          runSpacing: 8,
          children: edgeLegend,
        ),
      ],
    );
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
