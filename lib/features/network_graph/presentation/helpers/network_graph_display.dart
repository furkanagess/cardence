import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/graph_node.dart';
import '../../domain/entities/graph_node_type.dart';
import '../../domain/entities/network_graph.dart';

abstract final class NetworkGraphDisplay {
  static String nodeLabel(GraphNode node) {
    final label = node.label.trim();
    return label.isEmpty ? node.id : label;
  }

  static List<GraphNode> visibleNodes(List<GraphNode> nodes) =>
      nodes.where((node) => node.type != GraphNodeType.user).toList();

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
