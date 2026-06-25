import 'graph_edge.dart';
import 'graph_node.dart';
import 'graph_scope.dart';

class NetworkGraphMetrics {
  const NetworkGraphMetrics({
    required this.nodeCount,
    required this.edgeCount,
    this.centerCardId,
  });

  final int nodeCount;
  final int edgeCount;
  final String? centerCardId;
}

class NetworkGraph {
  const NetworkGraph({
    required this.scope,
    required this.nodes,
    required this.edges,
    required this.metrics,
  });

  final GraphScope scope;
  final List<GraphNode> nodes;
  final List<GraphEdge> edges;
  final NetworkGraphMetrics metrics;
}
