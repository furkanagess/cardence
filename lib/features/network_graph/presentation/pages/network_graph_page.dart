import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/widgets/atoms/cardence_app_bar.dart';
import '../../../../core/widgets/organisms/cardence_scaffold.dart';
import '../../domain/usecases/get_network_graph.dart';
import '../../domain/usecases/get_network_graph_path.dart';
import '../cubit/network_graph_cubit.dart';
import '../cubit/network_graph_state.dart';
import '../widgets/network_graph_edge_list.dart';
import '../widgets/network_graph_empty_state.dart';
import '../widgets/network_graph_node_list.dart';
import '../widgets/network_graph_overview_card.dart';

class NetworkGraphPage extends StatelessWidget {
  const NetworkGraphPage({
    super.key,
    required this.getNetworkGraph,
    required this.getNetworkGraphPath,
    this.centerCardId,
  });

  final GetNetworkGraph getNetworkGraph;
  final GetNetworkGraphPath getNetworkGraphPath;
  final String? centerCardId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => NetworkGraphCubit(
        getNetworkGraph: getNetworkGraph,
        getNetworkGraphPath: getNetworkGraphPath,
      )..loadPersonal(centerCardId: centerCardId),
      child: const NetworkGraphView(),
    );
  }
}

class NetworkGraphView extends StatelessWidget {
  const NetworkGraphView({super.key});

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
              onRetry: () => context.read<NetworkGraphCubit>().loadPersonal(),
            );
          }

          final graph = state.graph;
          if (graph == null || graph.nodes.isEmpty) {
            return NetworkGraphEmptyState(
              onRefresh: () => context.read<NetworkGraphCubit>().loadPersonal(),
            );
          }

          return RefreshIndicator(
            onRefresh: () => context.read<NetworkGraphCubit>().loadPersonal(),
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
                  'Kartların, şirketlerin ve etkinliklerin arasındaki bağlantılar backend graph servisi tarafından hesaplanır.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        height: 1.35,
                      ),
                ),
                const SizedBox(height: 16),
                NetworkGraphOverviewCard(graph: graph),
                const SizedBox(height: 24),
                NetworkGraphNodeList(nodes: graph.nodes),
                if (graph.edges.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  NetworkGraphEdgeList(edges: graph.edges),
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
