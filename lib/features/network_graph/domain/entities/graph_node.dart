import 'graph_node_type.dart';

class GraphNode {
  const GraphNode({
    required this.id,
    required this.type,
    required this.label,
    this.subtitle,
    this.cardId,
    this.company,
    this.degree = 0,
    this.isCenter = false,
    this.isOwnCard = false,
  });

  final String id;
  final GraphNodeType type;
  final String label;
  final String? subtitle;
  final String? cardId;
  final String? company;
  final int degree;
  final bool isCenter;
  final bool isOwnCard;
}
