import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/l10n/l10n_extensions.dart';
import '../../../../core/l10n/api_error_localizer.dart';
import '../../../event_groups/domain/usecases/get_event_groups.dart';
import '../../../../core/widgets/atoms/cardence_app_bar.dart';
import '../../../../core/widgets/atoms/custom_button.dart';
import '../../../../core/widgets/organisms/cardence_scaffold.dart';
import '../../domain/entities/graph_edge.dart';
import '../../domain/entities/graph_node.dart';
import '../../domain/entities/graph_scope.dart';
import '../../domain/entities/network_graph.dart';
import '../../domain/usecases/get_network_graph.dart';
import '../../domain/usecases/get_network_graph_path.dart';
import '../cubit/network_graph_cubit.dart';
import '../cubit/network_graph_state.dart';
import '../pages/network_graph_stats_page.dart';
import '../helpers/network_graph_canvas_theme.dart';
import '../widgets/network_graph_canvas.dart' show NetworkGraphInteractiveArea;
import '../widgets/network_graph_canvas_legend.dart';
import '../widgets/network_graph_empty_state.dart';
import '../helpers/network_graph_display.dart';
import '../widgets/network_graph_path_card.dart';
import '../widgets/network_graph_node_detail_card.dart';

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

class NetworkGraphView extends StatelessWidget {
  const NetworkGraphView({
    super.key,
    required this.getEventGroups,
    this.initialEventGroupName,
  });

  final GetEventGroups getEventGroups;
  final String? initialEventGroupName;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NetworkGraphCubit, NetworkGraphState>(
      builder: (context, state) {
        final graph = state.graph;
        final cubit = context.read<NetworkGraphCubit>();

        return CardenceScaffold(
          backgroundColor: NetworkGraphCanvasTheme.background(context),
          appBar: CardenceAppBar(
            title: context.l10n.networkGraph,
            variant: CardenceAppBarVariant.primary,
            actions: graph != null
                ? [
                    IconButton(
                      icon: const Icon(Icons.analytics_outlined),
                      tooltip: context.l10n.networkStatistics,
                      onPressed: () =>
                          NetworkGraphStatsPage.open(context, graph),
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
      return NetworkGraphEmptyState(
        onRefresh: () => cubit.reloadCurrent(),
      );
    }

    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final visibleNodes = NetworkGraphDisplay.visibleNodes(graph.nodes);
    final visibleEdges = NetworkGraphDisplay.visibleEdges(
      nodes: visibleNodes,
      edges: graph.edges,
    );
    final showPathPanel = state.isPathLoading ||
        state.path != null ||
        state.pathSourceCardId != null;
    final selectedNode = _selectedNode(state, visibleNodes);
    final showDetailPanel = !showPathPanel && selectedNode != null;

    return Stack(
      children: [
        Positioned.fill(
          child: NetworkGraphCanvasBackground(),
        ),
        Positioned.fill(
          child: state.isLoading
              ? const Center(child: CircularProgressIndicator())
              : NetworkGraphInteractiveArea(
                  nodes: visibleNodes,
                  edges: visibleEdges,
                  highlightedNodeIds: state.highlightedNodeIds,
                  pathNodeIds: state.path?.pathNodeIds ?? const [],
                  focusNodeIds: state.focusNodeIds,
                  onNodeTap: cubit.tapNode,
                ),
        ),
        const Positioned(
          top: 12,
          left: 12,
          child: NetworkGraphCanvasLegend(),
        ),
        if (showPathPanel)
          Positioned(
            left: 16,
            right: 16,
            bottom: 16 + bottomInset,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.sizeOf(context).height * 0.4,
              ),
              child: SingleChildScrollView(
                child: NetworkGraphPathCard(
                  path: state.path,
                  isLoading: state.isPathLoading,
                  pathSourceLabel: _getPathSourceLabel(state, context),
                  onClear: cubit.clearPathSelection,
                ),
              ),
            ),
          ),
        if (showDetailPanel)
          Positioned(
            left: 16,
            right: 16,
            bottom: 16 + bottomInset,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.sizeOf(context).height * 0.45,
              ),
              child: SingleChildScrollView(
                child: NetworkGraphNodeDetailCard(
                  node: selectedNode,
                  connectedNodes: NetworkGraphDisplay.connectedNodes(
                    nodeId: selectedNode.id,
                    nodes: visibleNodes,
                    edges: visibleEdges,
                  ),
                  relatedEdges: _relatedEdges(
                    nodeId: selectedNode.id,
                    edges: visibleEdges,
                  ),
                  onClear: cubit.clearNodeSelection,
                ),
              ),
            ),
          ),
      ],
    );
  }

  GraphNode? _selectedNode(
    NetworkGraphState state,
    List<GraphNode> visibleNodes,
  ) {
    final selectedNodeId = state.selectedNodeId;
    if (selectedNodeId == null) return null;
    for (final node in visibleNodes) {
      if (node.id == selectedNodeId) return node;
    }
    return null;
  }

  List<GraphEdge> _relatedEdges({
    required String nodeId,
    required List<GraphEdge> edges,
  }) {
    return edges
        .where((edge) => edge.source == nodeId || edge.target == nodeId)
        .toList();
  }

  String? _getPathSourceLabel(NetworkGraphState state, BuildContext context) {
    final cardId = state.pathSourceCardId;
    final graph = state.graph;
    if (cardId == null || graph == null) return null;

    for (final node in graph.nodes) {
      if (node.cardId == cardId || node.id == 'card:$cardId') {
        return NetworkGraphDisplay.nodeLabel(node);
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
            CustomButton.tonal(
              label: context.l10n.retry,
              icon: Icons.refresh_rounded,
              onPressed: onRetry,
              fullWidth: false,
            ),
          ],
        ),
      ),
    );
  }
}
