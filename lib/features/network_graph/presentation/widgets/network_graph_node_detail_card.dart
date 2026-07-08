import 'package:flutter/material.dart';

import '../../../../core/l10n/app_l10n.dart';
import '../../../../core/l10n/l10n_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/graph_edge.dart';
import '../../domain/entities/graph_edge_type.dart';
import '../../domain/entities/graph_node.dart';
import '../helpers/network_graph_canvas_theme.dart';
import '../helpers/network_graph_display.dart';
import 'network_graph_edge_list.dart';
import 'network_graph_node_list.dart';

class NetworkGraphNodeDetailCard extends StatelessWidget {
  const NetworkGraphNodeDetailCard({
    super.key,
    required this.node,
    required this.connectedNodes,
    required this.relatedEdges,
    this.onClear,
  });

  final GraphNode node;
  final List<GraphNode> connectedNodes;
  final List<GraphEdge> relatedEdges;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final brightness = theme.brightness;
    final l10n = context.l10n;
    final panelBackground =
        NetworkGraphCanvasTheme.nodeLabelBackground(brightness);
    final panelBorder = NetworkGraphCanvasTheme.nodeLabelBorder(brightness);
    final primaryText = AppColors.graphCanvasPrimaryTextFor(brightness);
    final secondaryText = AppColors.graphCanvasSecondaryTextFor(brightness);
    final edgeTypeCounts = _edgeTypeCounts(relatedEdges);

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: panelBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: panelBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: colorScheme.primaryContainer,
                  foregroundColor: colorScheme.onPrimaryContainer,
                  child: Icon(
                    NetworkGraphNodeIcon.iconFor(node.type),
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        NetworkGraphDisplay.nodeLabel(node),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: primaryText,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        node.subtitle ??
                            NetworkGraphNodeLabel.labelFor(l10n, node.type),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: secondaryText,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: AppL10n.clear(l10n),
                  onPressed: onClear,
                  icon: Icon(Icons.close_rounded, color: primaryText),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              l10n.networkGraphConnectedNodes(connectedNodes.length),
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: primaryText,
              ),
            ),
            const SizedBox(height: 8),
            if (connectedNodes.isEmpty)
              Text(
                l10n.networkGraphNoConnectedNodes,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: secondaryText,
                  height: 1.35,
                ),
              )
            else
              ...connectedNodes.take(8).map(NetworkGraphNodeTile.new),
            if (edgeTypeCounts.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                l10n.networkGraphConnectionTypes,
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: primaryText,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: edgeTypeCounts.entries
                    .map(
                      (entry) => _ConnectionTypeChip(
                        label: NetworkGraphEdgeLabel.labelFor(l10n, entry.key),
                        count: entry.value,
                      ),
                    )
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Map<GraphEdgeType, int> _edgeTypeCounts(List<GraphEdge> edges) {
    final counts = <GraphEdgeType, int>{};
    for (final edge in edges) {
      counts[edge.type] = (counts[edge.type] ?? 0) + 1;
    }
    return counts;
  }
}

class _ConnectionTypeChip extends StatelessWidget {
  const _ConnectionTypeChip({
    required this.label,
    required this.count,
  });

  final String label;
  final int count;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Text(
        '$label · $count',
        style: theme.textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
