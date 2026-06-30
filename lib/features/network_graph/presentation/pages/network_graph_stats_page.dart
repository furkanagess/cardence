import 'package:flutter/material.dart';

import '../../../../core/l10n/app_l10n.dart';
import '../../../../core/l10n/l10n_extensions.dart';
import '../../../../core/widgets/atoms/cardence_app_bar.dart';
import '../../../../core/widgets/organisms/cardence_scaffold.dart';
import '../../domain/entities/network_graph.dart';
import '../widgets/network_graph_edge_list.dart';
import '../widgets/network_graph_node_list.dart';

class NetworkGraphStatsPage extends StatelessWidget {
  const NetworkGraphStatsPage({
    super.key,
    required this.graph,
  });

  final NetworkGraph graph;

  static Future<void> open(BuildContext context, NetworkGraph graph) {
    return Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => NetworkGraphStatsPage(graph: graph),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return CardenceScaffold(
      appBar: CardenceAppBar(
        title: l10n.networkStatistics,
        variant: CardenceAppBarVariant.primary,
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          20,
          12,
          20,
          24 + MediaQuery.paddingOf(context).bottom,
        ),
        children: [
          _NetworkGraphStatItem(
            icon: Icons.hub_outlined,
            label: AppL10n.graphMetricNode(l10n),
            value: graph.metrics.nodeCount.toString(),
          ),
          const SizedBox(height: 12),
          _NetworkGraphStatItem(
            icon: Icons.route_outlined,
            label: AppL10n.graphMetricEdge(l10n),
            value: graph.metrics.edgeCount.toString(),
          ),
          const SizedBox(height: 12),
          _NetworkGraphStatItem(
            icon: Icons.center_focus_strong_outlined,
            label: AppL10n.graphMetricCenter(l10n),
            value: graph.metrics.centerCardId ?? l10n.you,
          ),
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 16),
          NetworkGraphNodeList(nodes: graph.nodes),
          if (graph.edges.isNotEmpty) ...[
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),
            NetworkGraphEdgeList(edges: graph.edges),
          ],
        ],
      ),
    );
  }
}

class _NetworkGraphStatItem extends StatelessWidget {
  const _NetworkGraphStatItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
            child: Icon(icon, color: colorScheme.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
