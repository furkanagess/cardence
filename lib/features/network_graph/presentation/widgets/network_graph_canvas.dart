import 'package:flutter/material.dart';

import '../../domain/entities/graph_edge.dart';
import '../../domain/entities/graph_node.dart';
import '../../domain/entities/graph_node_type.dart';
import '../helpers/network_graph_layout.dart';
import '../helpers/network_graph_node_style.dart';

class NetworkGraphCanvas extends StatelessWidget {
  const NetworkGraphCanvas({
    super.key,
    required this.nodes,
    required this.edges,
    this.highlightedNodeIds = const {},
    this.pathNodeIds = const [],
    this.onCardNodeTap,
  });

  final List<GraphNode> nodes;
  final List<GraphEdge> edges;
  final Set<String> highlightedNodeIds;
  final List<String> pathNodeIds;
  final ValueChanged<GraphNode>? onCardNodeTap;

  static const double height = 340;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final pathEndpoints = _pathEndpointIds();

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final size = Size(constraints.maxWidth, height);
            final layout = NetworkGraphLayout.compute(
              nodes: nodes,
              edges: edges,
              canvasSize: size,
            );

            return Stack(
              children: [
                CustomPaint(
                  size: size,
                  painter: _NetworkGraphEdgePainter(
                    layout: layout,
                    edges: edges,
                    pathNodeIds: pathNodeIds,
                    lineColor: Theme.of(context).colorScheme.outline,
                    highlightColor: Theme.of(context).colorScheme.primary,
                  ),
                ),
                ...layout.map((item) {
                  final highlighted = highlightedNodeIds.contains(item.node.id) ||
                      pathNodeIds.contains(item.node.id);
                  final isEndpoint = pathEndpoints.contains(item.node.id);
                  final style = NetworkGraphNodeStyle.forNode(
                    item.node,
                    isDark: isDark,
                    isHighlighted: highlighted,
                    isPathEndpoint: isEndpoint,
                  );
                  final left = item.offset.dx - (style.size / 2);
                  final top = item.offset.dy - (style.size / 2);

                  return Positioned(
                    left: left.clamp(8, size.width - style.size - 8),
                    top: top.clamp(8, size.height - style.size - 8),
                    child: _GraphNodeBubble(
                      node: item.node,
                      style: style,
                      onTap: item.node.type == GraphNodeType.card
                          ? onCardNodeTap
                          : null,
                    ),
                  );
                }),
              ],
            );
          },
        ),
      ),
    );
  }

  Set<String> _pathEndpointIds() {
    if (pathNodeIds.length < 2) return {};
    return {pathNodeIds.first, pathNodeIds.last};
  }
}

class _GraphNodeBubble extends StatelessWidget {
  const _GraphNodeBubble({
    required this.node,
    required this.style,
    this.onTap,
  });

  final GraphNode node;
  final NetworkGraphNodeStyle style;
  final ValueChanged<GraphNode>? onTap;

  @override
  Widget build(BuildContext context) {
    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: style.size,
          height: style.size,
          decoration: BoxDecoration(
            color: style.background,
            shape: BoxShape.circle,
            border: Border.all(color: style.border, width: node.isCenter ? 2.5 : 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Icon(style.icon, color: style.foreground, size: style.size * 0.38),
        ),
        const SizedBox(height: 4),
        SizedBox(
          width: style.size + 28,
          child: Text(
            node.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
      ],
    );

    if (onTap == null) return content;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onTap!(node),
        borderRadius: BorderRadius.circular(16),
        child: content,
      ),
    );
  }
}

class _NetworkGraphEdgePainter extends CustomPainter {
  _NetworkGraphEdgePainter({
    required this.layout,
    required this.edges,
    required this.pathNodeIds,
    required this.lineColor,
    required this.highlightColor,
  });

  final List<NetworkGraphLayoutPosition> layout;
  final List<GraphEdge> edges;
  final List<String> pathNodeIds;
  final Color lineColor;
  final Color highlightColor;

  @override
  void paint(Canvas canvas, Size size) {
    final positions = {
      for (final item in layout) item.node.id: item.offset,
    };

    for (final edge in edges) {
      final source = positions[edge.source];
      final target = positions[edge.target];
      if (source == null || target == null) continue;

      final onPath = _edgeOnPath(edge);
      final paint = Paint()
        ..color = (onPath ? highlightColor : lineColor)
            .withValues(alpha: onPath ? 0.9 : 0.35)
        ..strokeWidth = onPath ? 2.4 : 1.2
        ..style = PaintingStyle.stroke;

      canvas.drawLine(source, target, paint);
    }
  }

  bool _edgeOnPath(GraphEdge edge) {
    if (pathNodeIds.length < 2) return false;
    for (var i = 0; i < pathNodeIds.length - 1; i++) {
      final a = pathNodeIds[i];
      final b = pathNodeIds[i + 1];
      if ((edge.source == a && edge.target == b) ||
          (edge.source == b && edge.target == a)) {
        return true;
      }
    }
    return false;
  }

  @override
  bool shouldRepaint(covariant _NetworkGraphEdgePainter oldDelegate) =>
      oldDelegate.layout != layout ||
      oldDelegate.edges != edges ||
      oldDelegate.pathNodeIds != pathNodeIds;
}
