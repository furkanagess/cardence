import '../entities/graph_edge.dart';
import '../entities/graph_node.dart';
import '../entities/graph_node_type.dart';
import '../entities/network_graph.dart';
import '../entities/network_graph_path.dart';

class FindNetworkGraphPath {
  const FindNetworkGraphPath._();

  static NetworkGraphPath betweenCards({
    required NetworkGraph graph,
    required String fromCardId,
    required String toCardId,
  }) {
    final sourceId = _nodeIdForCard(graph.nodes, fromCardId);
    final targetId = _nodeIdForCard(graph.nodes, toCardId);
    if (sourceId == null || targetId == null || sourceId == targetId) {
      return const NetworkGraphPath(
        found: false,
        length: 0,
        nodes: [],
        edges: [],
        pathNodeIds: [],
      );
    }

    final pathNodeIds = _shortestPath(graph.edges, sourceId, targetId);
    if (pathNodeIds.isEmpty) {
      return const NetworkGraphPath(
        found: false,
        length: 0,
        nodes: [],
        edges: [],
        pathNodeIds: [],
      );
    }

    final pathNodeSet = pathNodeIds.toSet();
    final pathNodes =
        graph.nodes.where((node) => pathNodeSet.contains(node.id)).toList();
    final pathEdges = graph.edges
        .where(
          (edge) =>
              pathNodeSet.contains(edge.source) &&
              pathNodeSet.contains(edge.target) &&
              _areAdjacent(pathNodeIds, edge.source, edge.target),
        )
        .toList();

    return NetworkGraphPath(
      found: true,
      length: pathNodeIds.isNotEmpty ? pathNodeIds.length - 1 : 0,
      nodes: pathNodes,
      edges: pathEdges,
      pathNodeIds: pathNodeIds,
    );
  }

  static String? _nodeIdForCard(List<GraphNode> nodes, String cardId) {
    final normalized = cardId.trim();
    for (final node in nodes) {
      if (node.type != GraphNodeType.card) continue;
      if (node.cardId == normalized || node.id == 'card:$normalized') {
        return node.id;
      }
    }
    return null;
  }

  static List<String> _shortestPath(
    List<GraphEdge> edges,
    String source,
    String target,
  ) {
    if (source == target) return [source];

    final adjacency = <String, List<String>>{};
    for (final edge in edges) {
      adjacency.putIfAbsent(edge.source, () => []).add(edge.target);
      adjacency.putIfAbsent(edge.target, () => []).add(edge.source);
    }

    final queue = <String>[source];
    final visited = <String>{source};
    final previous = <String, String?>{source: null};

    while (queue.isNotEmpty) {
      final current = queue.removeAt(0);
      if (current == target) break;

      for (final neighbor in adjacency[current] ?? const []) {
        if (visited.contains(neighbor)) continue;
        visited.add(neighbor);
        previous[neighbor] = current;
        queue.add(neighbor);
      }
    }

    if (!previous.containsKey(target)) return [];

    final path = <String>[];
    var cursor = target;
    while (true) {
      path.add(cursor);
      final prev = previous[cursor];
      if (prev == null) break;
      cursor = prev;
    }
    return path.reversed.toList();
  }

  static bool _areAdjacent(List<String> path, String a, String b) {
    for (var i = 0; i < path.length - 1; i++) {
      final left = path[i];
      final right = path[i + 1];
      if ((left == a && right == b) || (left == b && right == a)) {
        return true;
      }
    }
    return false;
  }
}
