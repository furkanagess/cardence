import '../../domain/entities/graph_edge.dart';
import '../../domain/entities/graph_edge_type.dart';
import '../../domain/entities/graph_node.dart';
import '../../domain/entities/graph_node_type.dart';
import '../../domain/entities/graph_scope.dart';
import '../../domain/entities/network_graph.dart';
import '../../domain/entities/network_graph_path.dart';

class GraphNodeModel {
  const GraphNodeModel({
    required this.id,
    required this.type,
    required this.label,
    this.subtitle,
    this.cardId,
    this.company,
    this.photoUrl,
    this.degree = 0,
    this.isCenter = false,
    this.isOwnCard = false,
  });

  factory GraphNodeModel.fromJson(Map<String, dynamic> json) {
    return GraphNodeModel(
      id: (json['id'] ?? json['Id'] ?? '').toString(),
      type: (json['type'] ?? json['Type'] ?? 'card').toString(),
      label: (json['label'] ?? json['Label'] ?? '').toString(),
      subtitle: (json['subtitle'] ?? json['Subtitle'])?.toString(),
      cardId: (json['cardId'] ?? json['CardId'])?.toString(),
      company: (json['company'] ?? json['Company'])?.toString(),
      photoUrl: (json['photoUrl'] ?? json['PhotoUrl'])?.toString(),
      degree: (json['degree'] ?? json['Degree'] ?? 0) as int,
      isCenter: (json['isCenter'] ?? json['IsCenter'] ?? false) as bool,
      isOwnCard: (json['isOwnCard'] ?? json['IsOwnCard'] ?? false) as bool,
    );
  }

  final String id;
  final String type;
  final String label;
  final String? subtitle;
  final String? cardId;
  final String? company;
  final String? photoUrl;
  final int degree;
  final bool isCenter;
  final bool isOwnCard;

  GraphNode toEntity() {
    return GraphNode(
      id: id,
      type: GraphNodeTypeX.tryParse(type) ?? GraphNodeType.card,
      label: label,
      subtitle: subtitle,
      cardId: cardId,
      company: company,
      photoUrl: photoUrl,
      degree: degree,
      isCenter: isCenter,
      isOwnCard: isOwnCard,
    );
  }
}

class GraphEdgeModel {
  const GraphEdgeModel({
    required this.id,
    required this.source,
    required this.target,
    required this.type,
    this.weight = 1,
    this.occurredAt,
    this.eventGroupId,
    this.organizationEventId,
  });

  factory GraphEdgeModel.fromJson(Map<String, dynamic> json) {
    DateTime? occurredAt;
    final rawOccurred = json['occurredAt'] ?? json['OccurredAt'];
    if (rawOccurred is String && rawOccurred.isNotEmpty) {
      occurredAt = DateTime.tryParse(rawOccurred);
    }

    return GraphEdgeModel(
      id: (json['id'] ?? json['Id'] ?? '').toString(),
      source: (json['source'] ?? json['Source'] ?? '').toString(),
      target: (json['target'] ?? json['Target'] ?? '').toString(),
      type: (json['type'] ?? json['Type'] ?? 'saved').toString(),
      weight: (json['weight'] ?? json['Weight'] ?? 1) as int,
      occurredAt: occurredAt,
      eventGroupId: (json['eventGroupId'] ?? json['EventGroupId'])?.toString(),
      organizationEventId:
          (json['organizationEventId'] ?? json['OrganizationEventId'])
              ?.toString(),
    );
  }

  final String id;
  final String source;
  final String target;
  final String type;
  final int weight;
  final DateTime? occurredAt;
  final String? eventGroupId;
  final String? organizationEventId;

  GraphEdge toEntity() {
    return GraphEdge(
      id: id,
      source: source,
      target: target,
      type: GraphEdgeTypeX.tryParse(type) ?? GraphEdgeType.saved,
      weight: weight,
      occurredAt: occurredAt,
      eventGroupId: eventGroupId,
      organizationEventId: organizationEventId,
    );
  }
}

class NetworkGraphMetricsModel {
  const NetworkGraphMetricsModel({
    required this.nodeCount,
    required this.edgeCount,
    this.centerCardId,
  });

  factory NetworkGraphMetricsModel.fromJson(Map<String, dynamic> json) {
    return NetworkGraphMetricsModel(
      nodeCount: (json['nodeCount'] ?? json['NodeCount'] ?? 0) as int,
      edgeCount: (json['edgeCount'] ?? json['EdgeCount'] ?? 0) as int,
      centerCardId: (json['centerCardId'] ?? json['CenterCardId'])?.toString(),
    );
  }

  final int nodeCount;
  final int edgeCount;
  final String? centerCardId;

  NetworkGraphMetrics toEntity() => NetworkGraphMetrics(
        nodeCount: nodeCount,
        edgeCount: edgeCount,
        centerCardId: centerCardId,
      );
}

class NetworkGraphModel {
  const NetworkGraphModel({
    required this.scope,
    required this.nodes,
    required this.edges,
    required this.metrics,
  });

  factory NetworkGraphModel.fromJson(Map<String, dynamic> json) {
    final rawNodes = json['nodes'] ?? json['Nodes'];
    final rawEdges = json['edges'] ?? json['Edges'];
    final rawMetrics = json['metrics'] ?? json['Metrics'];

    return NetworkGraphModel(
      scope: (json['scope'] ?? json['Scope'] ?? 'personal').toString(),
      nodes: rawNodes is List
          ? rawNodes
              .whereType<Map<String, dynamic>>()
              .map(GraphNodeModel.fromJson)
              .toList()
          : const [],
      edges: rawEdges is List
          ? rawEdges
              .whereType<Map<String, dynamic>>()
              .map(GraphEdgeModel.fromJson)
              .toList()
          : const [],
      metrics: rawMetrics is Map<String, dynamic>
          ? NetworkGraphMetricsModel.fromJson(rawMetrics)
          : const NetworkGraphMetricsModel(nodeCount: 0, edgeCount: 0),
    );
  }

  final String scope;
  final List<GraphNodeModel> nodes;
  final List<GraphEdgeModel> edges;
  final NetworkGraphMetricsModel metrics;

  GraphScope _parseScope() {
    switch (scope.toLowerCase()) {
      case 'event':
        return GraphScope.event;
      case 'organization':
        return GraphScope.organization;
      default:
        return GraphScope.personal;
    }
  }

  NetworkGraph toEntity() => NetworkGraph(
        scope: _parseScope(),
        nodes: nodes.map((n) => n.toEntity()).toList(),
        edges: edges.map((e) => e.toEntity()).toList(),
        metrics: metrics.toEntity(),
      );
}

class NetworkGraphPathModel {
  const NetworkGraphPathModel({
    required this.found,
    required this.length,
    required this.nodes,
    required this.edges,
    required this.pathNodeIds,
  });

  factory NetworkGraphPathModel.fromJson(Map<String, dynamic> json) {
    final rawNodes = json['nodes'] ?? json['Nodes'];
    final rawEdges = json['edges'] ?? json['Edges'];
    final rawPath = json['pathNodeIds'] ?? json['PathNodeIds'];

    return NetworkGraphPathModel(
      found: (json['found'] ?? json['Found'] ?? false) as bool,
      length: (json['length'] ?? json['Length'] ?? 0) as int,
      nodes: rawNodes is List
          ? rawNodes
              .whereType<Map<String, dynamic>>()
              .map(GraphNodeModel.fromJson)
              .toList()
          : const [],
      edges: rawEdges is List
          ? rawEdges
              .whereType<Map<String, dynamic>>()
              .map(GraphEdgeModel.fromJson)
              .toList()
          : const [],
      pathNodeIds: rawPath is List
          ? rawPath.map((e) => e.toString()).toList()
          : const [],
    );
  }

  final bool found;
  final int length;
  final List<GraphNodeModel> nodes;
  final List<GraphEdgeModel> edges;
  final List<String> pathNodeIds;

  NetworkGraphPath toEntity() => NetworkGraphPath(
        found: found,
        length: length,
        nodes: nodes.map((n) => n.toEntity()).toList(),
        edges: edges.map((e) => e.toEntity()).toList(),
        pathNodeIds: pathNodeIds,
      );
}
