import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/l10n/l10n_extensions.dart';
import '../../../../core/l10n/api_error_localizer.dart';

import '../../../event_groups/domain/entities/event_group.dart';
import '../../../event_groups/domain/usecases/get_event_groups.dart';
import '../../../../core/widgets/atoms/cardence_app_bar.dart';
import '../../../../core/widgets/organisms/cardence_scaffold.dart';
import '../../../../core/l10n/app_l10n.dart';
import '../../domain/entities/graph_scope.dart';
import '../../domain/entities/network_graph.dart';
import '../../domain/usecases/get_network_graph.dart';
import '../../domain/usecases/get_network_graph_path.dart';
import '../cubit/network_graph_cubit.dart';
import '../cubit/network_graph_state.dart';
import '../widgets/network_graph_canvas.dart';
import '../widgets/network_graph_edge_list.dart';
import '../widgets/network_graph_empty_state.dart';
import '../widgets/network_graph_legend.dart';
import '../widgets/network_graph_node_list.dart';
import '../widgets/network_graph_path_card.dart';
import '../widgets/network_graph_scope_bar.dart';

class NetworkGraphPage extends StatelessWidget {
  const NetworkGraphPage({
    super.key,
    required this.getNetworkGraph,
    required this.getNetworkGraphPath,
    required this.getEventGroups,
    this.centerCardId,
    this.initialScope = GraphScope.personal,
    this.initialEventGroupId,
    this.initialEventGroupName,
  });

  final GetNetworkGraph getNetworkGraph;
  final GetNetworkGraphPath getNetworkGraphPath;
  final GetEventGroups getEventGroups;
  final String? centerCardId;
  final GraphScope initialScope;
  final String? initialEventGroupId;
  final String? initialEventGroupName;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => NetworkGraphCubit(
        getNetworkGraph: getNetworkGraph,
      )..loadInitial(
          scope: initialScope,
          eventGroupId: initialEventGroupId,
          centerCardId: centerCardId,
        ),
      child: NetworkGraphView(
        getEventGroups: getEventGroups,
        initialEventGroupName: initialEventGroupName,
      ),
    );
  }
}

class NetworkGraphView extends StatefulWidget {
  const NetworkGraphView({
    super.key,
    required this.getEventGroups,
    this.initialEventGroupName,
  });

  final GetEventGroups getEventGroups;
  final String? initialEventGroupName;

  @override
  State<NetworkGraphView> createState() => _NetworkGraphViewState();
}

class _NetworkGraphViewState extends State<NetworkGraphView> {
  List<EventGroup> _eventGroups = [];
  bool _loadingGroups = true;

  @override
  void initState() {
    super.initState();
    _loadEventGroups();
  }

  Future<void> _loadEventGroups() async {
    final groups = await widget.getEventGroups();
    if (!mounted) return;
    setState(() {
      _eventGroups = groups;
      _loadingGroups = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NetworkGraphCubit, NetworkGraphState>(
      builder: (context, state) {
        final graph = state.graph;
        final cubit = context.read<NetworkGraphCubit>();

        return CardenceScaffold(
          appBar: CardenceAppBar(
            title: context.l10n.networkGraph,
            variant: CardenceAppBarVariant.primary,
            actions: graph != null
                ? [
                    IconButton(
                      icon: const Icon(Icons.info_outline_rounded),
                      tooltip: context.l10n.hakknda,
                      onPressed: () =>
                          _showGraphInfoDialog(context, state.scope),
                    ),
                    IconButton(
                      icon: const Icon(Icons.analytics_outlined),
                      tooltip: context.l10n.networkStatistics,
                      onPressed: () => _showGraphStatsDialog(context, graph),
                    ),
                  ]
                : null,
          ),
          body: _buildBody(context, state, graph, cubit),
        );
      },
    );
  }

  Widget _buildBody(
    BuildContext context,
    NetworkGraphState state,
    NetworkGraph? graph,
    NetworkGraphCubit cubit,
  ) {
    if (state.status == NetworkGraphStatus.loading && graph == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.status == NetworkGraphStatus.failure && graph == null) {
      return NetworkGraphErrorState(
        message: state.errorMessage != null
            ? ApiErrorLocalizer.localize(context.l10n, state.errorMessage!)
            : context.l10n.networkGraphLoadFailed,
        onRetry: () => cubit.reloadCurrent(),
      );
    }

    if (graph == null || graph.nodes.isEmpty) {
      return Column(
        children: [
          Expanded(
            child: NetworkGraphEmptyState(
              onRefresh: () => cubit.reloadCurrent(),
            ),
          ),
          if (!_loadingGroups)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              child: NetworkGraphScopeBar(
                scope: state.scope,
                eventGroups: _eventGroups,
                selectedEventGroupId: state.eventGroupId,
                onPersonalSelected: () => cubit.selectPersonalScope(),
                onEventSelected: (group) => cubit.selectEventScope(group.id),
              ),
            ),
        ],
      );
    }

    return RefreshIndicator(
      onRefresh: cubit.reloadCurrent,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(
          20,
          12,
          20,
          32 + MediaQuery.paddingOf(context).bottom,
        ),
        children: [
          if (!_loadingGroups)
            NetworkGraphScopeBar(
              scope: state.scope,
              eventGroups: _eventGroups,
              selectedEventGroupId: state.eventGroupId,
              onPersonalSelected: cubit.selectPersonalScope,
              onEventSelected: (group) =>
                  cubit.selectEventScope(group.id),
            ),
          if (state.scope == GraphScope.event &&
              widget.initialEventGroupName != null &&
              state.eventGroupId != null) ...[
            const SizedBox(height: 8),
            Text(
              widget.initialEventGroupName!,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ],
          const SizedBox(height: 16),
          if (state.isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: CircularProgressIndicator()),
            )
          else ...[
            NetworkGraphCanvas(
              nodes: graph.nodes,
              edges: graph.edges,
              highlightedNodeIds: state.highlightedNodeIds,
              pathNodeIds: state.path?.pathNodeIds ?? const [],
              onCardNodeTap: cubit.tapCardNode,
            ),
            const SizedBox(height: 16),
            NetworkGraphPathCard(
              path: state.path,
              isLoading: state.isPathLoading,
              pathSourceLabel: _getPathSourceLabel(state, context),
              onClear: cubit.clearPathSelection,
            ),
          ],
        ],
      ),
    );
  }

  void _showGraphInfoDialog(BuildContext context, GraphScope scope) {
    final theme = Theme.of(context);
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          icon: Icon(
            Icons.info_outline_rounded,
            color: theme.colorScheme.primary,
            size: 32,
          ),
          title: Text(
            context.l10n.networkGraph,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    scope == GraphScope.event
                        ? context.l10n.networkGraphEventDescription
                        : context.l10n.networkGraphPersonalDescription,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 16),
                  const NetworkGraphLegend(),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(context.l10n.close),
            ),
          ],
        );
      },
    );
  }

  void _showGraphStatsDialog(BuildContext context, NetworkGraph graph) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.analytics_outlined, color: colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                context.l10n.networkStatistics,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatItem(
                    context,
                    icon: Icons.hub_outlined,
                    label: AppL10n.graphMetricNode(context.l10n),
                    value: graph.metrics.nodeCount.toString(),
                  ),
                  const SizedBox(height: 12),
                  _buildStatItem(
                    context,
                    icon: Icons.route_outlined,
                    label: AppL10n.graphMetricEdge(context.l10n),
                    value: graph.metrics.edgeCount.toString(),
                  ),
                  const SizedBox(height: 12),
                  _buildStatItem(
                    context,
                    icon: Icons.center_focus_strong_outlined,
                    label: AppL10n.graphMetricCenter(context.l10n),
                    value: graph.metrics.centerCardId ?? context.l10n.you,
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
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(context.l10n.close),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
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

  String? _getPathSourceLabel(NetworkGraphState state, BuildContext context) {
    final cardId = state.pathSourceCardId;
    final graph = state.graph;
    if (cardId == null || graph == null) return null;

    for (final node in graph.nodes) {
      if (node.cardId == cardId || node.id == 'card:$cardId') {
        return node.isOwnCard ? context.l10n.you : node.label;
      }
    }
    return cardId;
  }
}

class NetworkGraphErrorState extends StatelessWidget {
  const NetworkGraphErrorState({
    super.key,
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 52,
              color: colorScheme.error,
            ),
            const SizedBox(height: 14),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 18),
            FilledButton.tonalIcon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: Text(context.l10n.retry),
            ),
          ],
        ),
      ),
    );
  }
}
