import 'package:flutter/material.dart';

import '../../domain/entities/graph_node_type.dart';
import 'network_graph_node_list.dart';

class NetworkGraphLegend extends StatelessWidget {
  const NetworkGraphLegend({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    const types = [
      GraphNodeType.card,
      GraphNodeType.company,
      GraphNodeType.event,
      GraphNodeType.user,
    ];

    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: types.map((type) {
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
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ],
        );
      }).toList(),
    );
  }
}
