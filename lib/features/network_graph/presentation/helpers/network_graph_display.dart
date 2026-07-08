import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/graph_edge.dart';
import '../../domain/entities/graph_node.dart';
import '../../domain/entities/graph_node_type.dart';
import '../../domain/entities/network_graph.dart';

abstract final class NetworkGraphDisplay {
  static const Set<GraphNodeType> _hiddenTypes = {
    GraphNodeType.user,
    GraphNodeType.skill,
    GraphNodeType.location,
  };

  static String nodeLabel(GraphNode node) {
    final label = node.label.trim();
    return label.isEmpty ? node.id : label;
  }

  static List<GraphNode> visibleNodes(List<GraphNode> nodes) =>
      nodes.where((node) => !_hiddenTypes.contains(node.type)).toList();

  static List<GraphEdge> visibleEdges({
    required List<GraphNode> nodes,
    required List<GraphEdge> edges,
  }) {
    final visibleIds = nodes.map((node) => node.id).toSet();
    return edges
        .where(
          (edge) =>
              visibleIds.contains(edge.source) &&
              visibleIds.contains(edge.target),
        )
        .toList();
  }

  static bool isTappable(GraphNode node) {
    return switch (node.type) {
      GraphNodeType.card ||
      GraphNodeType.company ||
      GraphNodeType.event ||
      GraphNodeType.organization ||
      GraphNodeType.organizationEvent =>
        true,
      _ => false,
    };
  }

  static Set<String> neighborIds(String nodeId, List<GraphEdge> edges) {
    final ids = <String>{};
    for (final edge in edges) {
      if (edge.source == nodeId) ids.add(edge.target);
      if (edge.target == nodeId) ids.add(edge.source);
    }
    return ids;
  }

  static List<GraphNode> connectedNodes({
    required String nodeId,
    required List<GraphNode> nodes,
    required List<GraphEdge> edges,
  }) {
    final neighborIdSet = neighborIds(nodeId, edges);
    return nodes
        .where((node) => neighborIdSet.contains(node.id))
        .toList()
      ..sort((a, b) {
        final degreeCompare = b.degree.compareTo(a.degree);
        if (degreeCompare != 0) return degreeCompare;
        return nodeLabel(a).compareTo(nodeLabel(b));
      });
  }

  static Set<String> focusNodeIds({
    required String? selectedNodeId,
    required List<GraphNode> nodes,
    required List<GraphEdge> edges,
  }) {
    if (selectedNodeId == null) return {};
    final focus = <String>{selectedNodeId};
    focus.addAll(neighborIds(selectedNodeId, edges));
    return focus;
  }

  static String centerMetricValue(NetworkGraph graph, AppLocalizations l10n) {
    final centerCardId = graph.metrics.centerCardId?.trim();
    if (centerCardId != null && centerCardId.isNotEmpty) {
      for (final node in graph.nodes) {
        if (node.cardId == centerCardId) {
          return nodeLabel(node);
        }
      }
      return centerCardId;
    }

    for (final node in graph.nodes) {
      if (node.isCenter) {
        return nodeLabel(node);
      }
    }

    for (final node in graph.nodes) {
      if (node.isOwnCard) {
        return nodeLabel(node);
      }
    }

    return l10n.graphMetricCenterFallback;
  }
}
