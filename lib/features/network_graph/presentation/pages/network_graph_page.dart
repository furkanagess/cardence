import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../event_groups/domain/entities/event_group.dart';
import '../../../event_groups/domain/usecases/get_event_groups.dart';
import '../../../../core/widgets/atoms/cardence_app_bar.dart';
import '../../../../core/widgets/organisms/cardence_scaffold.dart';
import '../../domain/entities/graph_scope.dart';
import '../../domain/usecases/get_network_graph.dart';
import '../../domain/usecases/get_network_graph_path.dart';
import '../cubit/network_graph_cubit.dart';
import '../cubit/network_graph_state.dart';
import '../widgets/network_graph_canvas.dart';
import '../widgets/network_graph_edge_list.dart';
import '../widgets/network_graph_empty_state.dart';
import '../widgets/network_graph_legend.dart';
import '../widgets/network_graph_node_list.dart';
import '../widgets/network_graph_overview_card.dart';
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
    return CardenceScaffold(
      appBar: const CardenceAppBar(
        title: 'Ağ Grafiği',
        variant: CardenceAppBarVariant.primary,
      ),
      body: BlocBuilder<NetworkGraphCubit, NetworkGraphState>(
        builder: (context, state) {
          if (state.status == NetworkGraphStatus.loading &&
              state.graph == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == NetworkGraphStatus.failure &&
              state.graph == null) {
            return NetworkGraphErrorState(
              message: state.errorMessage ?? 'Ağ grafiği alınamadı.',
              onRetry: () => context.read<NetworkGraphCubit>().reloadCurrent(),
            );
          }

          final graph = state.graph;
          if (graph == null || graph.nodes.isEmpty) {
            return Column(
              children: [
                Expanded(
                  child: NetworkGraphEmptyState(
                    onRefresh: () =>
                        context.read<NetworkGraphCubit>().reloadCurrent(),
                  ),
                ),
                if (!_loadingGroups)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                    child: NetworkGraphScopeBar(
                      scope: state.scope,
                      eventGroups: _eventGroups,
                      selectedEventGroupId: state.eventGroupId,
                      onPersonalSelected: () =>
                          context.read<NetworkGraphCubit>().selectPersonalScope(),
                      onEventSelected: (group) => context
                          .read<NetworkGraphCubit>()
                          .selectEventScope(group.id),
                    ),
                  ),
              ],
            );
          }

          final cubit = context.read<NetworkGraphCubit>();

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
                Text(
                  state.scope == GraphScope.event
                      ? 'Bu etkinlikteki kartlar, şirketler ve bağlantılar görsel olarak gösterilir.'
                      : 'Kartlarınız, kayıtlı kartlar ve şirket/etkinlik düğümleri arasındaki ilişkiler.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        height: 1.35,
                      ),
                ),
                const SizedBox(height: 16),
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
                  NetworkGraphOverviewCard(graph: graph),
                  const SizedBox(height: 16),
                  NetworkGraphCanvas(
                    nodes: graph.nodes,
                    edges: graph.edges,
                    highlightedNodeIds: state.highlightedNodeIds,
                    pathNodeIds: state.path?.pathNodeIds ?? const [],
                    onCardNodeTap: cubit.tapCardNode,
                  ),
                  const SizedBox(height: 12),
                  const NetworkGraphLegend(),
                  const SizedBox(height: 16),
                  NetworkGraphPathCard(
                    path: state.path,
                    isLoading: state.isPathLoading,
                    pathSourceLabel: cubit.pathSourceLabel(),
                    onClear: cubit.clearPathSelection,
                  ),
                  const SizedBox(height: 24),
                  NetworkGraphNodeList(nodes: graph.nodes),
                  if (graph.edges.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    NetworkGraphEdgeList(edges: graph.edges),
                  ],
                ],
              ],
            ),
          );
        },
      ),
    );
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
              label: const Text('Tekrar dene'),
            ),
          ],
        ),
      ),
    );
  }
}
