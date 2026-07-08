import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../domain/entities/graph_edge.dart';
import '../../domain/entities/graph_node.dart';
import '../../domain/entities/graph_node_type.dart';

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

  static const List<double> _ringRadiusFactors = [0, 0.2, 0.33, 0.46, 0.56];

  static List<NetworkGraphLayoutPosition> compute({
    required List<GraphNode> nodes,
    required List<GraphEdge> edges,
    required Size canvasSize,
  }) {
    if (nodes.isEmpty) return [];

    final center = Offset(canvasSize.width / 2, canvasSize.height / 2);
    final minSide = math.min(canvasSize.width, canvasSize.height);
    final centerNode = _resolveCenterNode(nodes);

    final positions = <String, Offset>{};
    final sizes = <String, double>{};
    positions[centerNode.id] = center;
    sizes[centerNode.id] = _sizeFor(centerNode);

    final placed = <String>{centerNode.id};
    final grouped = <int, List<GraphNode>>{};

    for (final node in nodes) {
      if (node.id == centerNode.id) continue;
      grouped.putIfAbsent(_ringIndex(node), () => []).add(node);
    }

    for (final ringIndex in [1, 2, 3, 4]) {
      final ringNodes = grouped[ringIndex];
      if (ringNodes == null || ringNodes.isEmpty) continue;

      ringNodes.sort((a, b) {
        final centerNeighborCompare = (_isDirectNeighbor(b.id, centerNode.id, edges)
                ? 1
                : 0)
            .compareTo(
              _isDirectNeighbor(a.id, centerNode.id, edges) ? 1 : 0,
            );
        if (centerNeighborCompare != 0) return centerNeighborCompare;
        final degreeCompare = b.degree.compareTo(a.degree);
        if (degreeCompare != 0) return degreeCompare;
        return a.label.compareTo(b.label);
      });

      _placeOnRing(
        nodes: ringNodes,
        center: center,
        radius: minSide * _ringRadiusFactors[ringIndex],
        positions: positions,
        sizes: sizes,
        placed: placed,
      );
    }

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

  static GraphNode _resolveCenterNode(List<GraphNode> nodes) {
    return nodes.firstWhere(
      (node) => node.isCenter,
      orElse: () => nodes.firstWhere(
        (node) => node.isOwnCard,
        orElse: () => nodes.reduce(
          (best, node) => node.degree >= best.degree ? node : best,
        ),
      ),
    );
  }

  static int _ringIndex(GraphNode node) {
    if (node.isCenter || node.isOwnCard) return 0;
    return switch (node.type) {
      GraphNodeType.card => 1,
      GraphNodeType.company || GraphNodeType.organization => 2,
      GraphNodeType.event || GraphNodeType.organizationEvent => 3,
      _ => 4,
    };
  }

  static bool _isDirectNeighbor(
    String nodeId,
    String centerNodeId,
    List<GraphEdge> edges,
  ) {
    for (final edge in edges) {
      if (edge.source == centerNodeId && edge.target == nodeId) return true;
      if (edge.target == centerNodeId && edge.source == nodeId) return true;
    }
    return false;
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

  static double _sizeFor(GraphNode node) {
    if (node.isOwnCard) return 58;
    if (node.isCenter) return 54;

    final base = switch (node.type) {
      GraphNodeType.card => 44 + (node.degree.clamp(0, 8) * 3),
      GraphNodeType.company || GraphNodeType.organization =>
        36 + (node.degree.clamp(0, 6) * 2),
      GraphNodeType.event || GraphNodeType.organizationEvent =>
        38 + (node.degree.clamp(0, 6) * 2),
      _ => 34 + node.degree.clamp(0, 4),
    };

    return base.toDouble().clamp(34, 68);
  }
}
