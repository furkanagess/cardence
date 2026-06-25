import 'graph_edge_type.dart';

class GraphEdge {
  const GraphEdge({
    required this.id,
    required this.source,
    required this.target,
    required this.type,
    this.weight = 1,
    this.occurredAt,
    this.eventGroupId,
    this.organizationEventId,
  });

  final String id;
  final String source;
  final String target;
  final GraphEdgeType type;
  final int weight;
  final DateTime? occurredAt;
  final String? eventGroupId;
  final String? organizationEventId;
}
