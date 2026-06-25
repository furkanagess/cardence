import 'graph_edge.dart';
import 'graph_node.dart';

class NetworkGraphPath {
  const NetworkGraphPath({
    required this.found,
    required this.length,
    required this.nodes,
    required this.edges,
    required this.pathNodeIds,
  });

  final bool found;
  final int length;
  final List<GraphNode> nodes;
  final List<GraphEdge> edges;
  final List<String> pathNodeIds;
}
