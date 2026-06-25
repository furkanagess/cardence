import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../domain/entities/graph_edge.dart';
import '../../domain/entities/graph_node.dart';

class NetworkGraphLayoutPosition {
  const NetworkGraphLayoutPosition({
    required this.node,
    required this.offset,
    required this.size,
  });

  final GraphNode node;
  final Offset offset;
  final double size;
}

class NetworkGraphLayout {
  const NetworkGraphLayout._();

  static List<NetworkGraphLayoutPosition> compute({
    required List<GraphNode> nodes,
    required List<GraphEdge> edges,
    required Size canvasSize,
  }) {
    if (nodes.isEmpty) return [];

    final center = Offset(canvasSize.width / 2, canvasSize.height / 2);
    final centerNode = nodes.firstWhere(
      (node) => node.isCenter,
      orElse: () => nodes.firstWhere(
        (node) => node.isOwnCard,
        orElse: () => nodes.reduce(
          (best, node) => node.degree >= best.degree ? node : best,
        ),
      ),
    );

    final positions = <String, Offset>{};
    final sizes = <String, double>{};
    positions[centerNode.id] = center;
    sizes[centerNode.id] = _sizeFor(centerNode);

    final neighbors = _neighborIds(centerNode.id, edges);
    final ringOne = nodes
        .where((node) => node.id != centerNode.id && neighbors.contains(node.id))
        .toList()
      ..sort((a, b) => b.degree.compareTo(a.degree));

    final placed = <String>{centerNode.id};
    _placeOnRing(
      nodes: ringOne,
      center: center,
      radius: math.min(canvasSize.width, canvasSize.height) * 0.24,
      positions: positions,
      sizes: sizes,
      placed: placed,
    );

    final ringTwo = nodes
        .where((node) => !placed.contains(node.id))
        .toList()
      ..sort((a, b) => b.degree.compareTo(a.degree));

    _placeOnRing(
      nodes: ringTwo,
      center: center,
      radius: math.min(canvasSize.width, canvasSize.height) * 0.38,
      positions: positions,
      sizes: sizes,
      placed: placed,
    );

    return nodes
        .where((node) => positions.containsKey(node.id))
        .map(
          (node) => NetworkGraphLayoutPosition(
            node: node,
            offset: positions[node.id]!,
            size: sizes[node.id] ?? _sizeFor(node),
          ),
        )
        .toList();
  }

  static Set<String> _neighborIds(String nodeId, List<GraphEdge> edges) {
    final ids = <String>{};
    for (final edge in edges) {
      if (edge.source == nodeId) ids.add(edge.target);
      if (edge.target == nodeId) ids.add(edge.source);
    }
    return ids;
  }

  static void _placeOnRing({
    required List<GraphNode> nodes,
    required Offset center,
    required double radius,
    required Map<String, Offset> positions,
    required Map<String, double> sizes,
    required Set<String> placed,
  }) {
    if (nodes.isEmpty) return;
    final step = (2 * math.pi) / nodes.length;
    var angle = -math.pi / 2;
    for (final node in nodes) {
      positions[node.id] = Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );
      sizes[node.id] = _sizeFor(node);
      placed.add(node.id);
      angle += step;
    }
  }

  static double _sizeFor(GraphNode node) =>
      (44 + (node.degree.clamp(0, 8) * 3)).toDouble().clamp(44, 68);
}
