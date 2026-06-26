import 'package:flutter/material.dart';

import '../../../../core/l10n/app_l10n.dart';
import '../../../../core/l10n/l10n_extensions.dart';
import '../../domain/entities/network_graph.dart';

class NetworkGraphOverviewCard extends StatelessWidget {
  const NetworkGraphOverviewCard({
    super.key,
    required this.graph,
  });

  final NetworkGraph graph;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = context.l10n;

    return Card(
      elevation: 0,
      color: colorScheme.primaryContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Expanded(
              child: NetworkGraphMetricTile(
                label: AppL10n.graphMetricNode(l10n),
                value: graph.metrics.nodeCount.toString(),
              ),
            ),
            Container(
              width: 1,
              height: 42,
              color: colorScheme.onPrimaryContainer.withValues(alpha: 0.18),
            ),
            Expanded(
              child: NetworkGraphMetricTile(
                label: AppL10n.graphMetricEdge(l10n),
                value: graph.metrics.edgeCount.toString(),
              ),
            ),
            Container(
              width: 1,
              height: 42,
              color: colorScheme.onPrimaryContainer.withValues(alpha: 0.18),
            ),
            Expanded(
              child: NetworkGraphMetricTile(
                label: AppL10n.graphMetricCenter(l10n),
                value: graph.metrics.centerCardId ?? AppL10n.you(l10n),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NetworkGraphMetricTile extends StatelessWidget {
  const NetworkGraphMetricTile({
    super.key,
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme.onPrimaryContainer;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.titleLarge?.copyWith(
            color: color,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: color.withValues(alpha: 0.72),
          ),
        ),
      ],
    );
  }
}
