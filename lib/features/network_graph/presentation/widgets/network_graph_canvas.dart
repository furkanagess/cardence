import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/l10n/l10n_extensions.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/atoms/cardence_app_bar.dart';
import '../../../../core/widgets/atoms/profile_avatar.dart';
import '../../domain/entities/graph_edge.dart';
import '../../domain/entities/graph_edge_type.dart';
import '../../domain/entities/graph_node.dart';
import '../../domain/entities/graph_node_type.dart';
import '../helpers/network_graph_canvas_theme.dart';
import '../widgets/network_graph_canvas_legend.dart';
import '../helpers/network_graph_display.dart';
import '../helpers/network_graph_layout.dart';
import '../helpers/network_graph_node_style.dart';

class NetworkGraphCanvas extends StatelessWidget {
  const NetworkGraphCanvas({
    super.key,
    required this.nodes,
    required this.edges,
    this.highlightedNodeIds = const {},
    this.pathNodeIds = const [],
    this.focusNodeIds = const {},
    this.onNodeTap,
  });

  final List<GraphNode> nodes;
  final List<GraphEdge> edges;
  final Set<String> highlightedNodeIds;
  final List<String> pathNodeIds;
  final Set<String> focusNodeIds;
  final ValueChanged<GraphNode>? onNodeTap;

  static const double height = 420;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final brightness = Theme.of(context).brightness;
    final canvasBackground = NetworkGraphCanvasTheme.background(context);
    final labelBorder = NetworkGraphCanvasTheme.nodeLabelBorder(brightness);

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: canvasBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: labelBorder),
      ),
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: Stack(
          children: [
            Positioned.fill(
              child: NetworkGraphCanvasBackground(
                child: NetworkGraphArea(
                  nodes: nodes,
                  edges: edges,
                  highlightedNodeIds: highlightedNodeIds,
                  pathNodeIds: pathNodeIds,
                  focusNodeIds: focusNodeIds,
                  onNodeTap: onNodeTap,
                ),
              ),
            ),
            Positioned(
              top: 10,
              left: 10,
              child: const NetworkGraphCanvasLegend(),
            ),
            Positioned(
              top: 10,
              right: 10,
              child: DecoratedBox(
                decoration: NetworkGraphCanvasTheme.fullscreenButtonDecoration(
                  context,
                  colorScheme.primary,
                ),
                child: IconButton(
                  tooltip: 'Tam ekran',
                  icon: Icon(
                    Icons.fullscreen_rounded,
                    color: colorScheme.primary,
                  ),
                  onPressed: () => _openFullscreen(context),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openFullscreen(BuildContext context) {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (_) => _NetworkGraphFullscreenView(
          nodes: nodes,
          edges: edges,
          highlightedNodeIds: highlightedNodeIds,
          pathNodeIds: pathNodeIds,
          focusNodeIds: focusNodeIds,
          onNodeTap: onNodeTap,
        ),
      ),
    );
  }
}

/// Grafik çizim alanı (kenarlar + düğümler). Inline ve tam ekran için ortak.
class NetworkGraphArea extends StatelessWidget {
  const NetworkGraphArea({
    super.key,
    required this.nodes,
    required this.edges,
    this.highlightedNodeIds = const {},
    this.pathNodeIds = const [],
    this.focusNodeIds = const {},
    this.onNodeTap,
  });

  final List<GraphNode> nodes;
  final List<GraphEdge> edges;
  final Set<String> highlightedNodeIds;
  final List<String> pathNodeIds;
  final Set<String> focusNodeIds;
  final ValueChanged<GraphNode>? onNodeTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brightness = theme.brightness;
    final isDark = brightness == Brightness.dark;
    final pathEndpoints = _pathEndpointIds();

    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        final layout = NetworkGraphLayout.compute(
          nodes: nodes,
          edges: edges,
          canvasSize: size,
        );

        return Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: _NetworkGraphEdgePainter(
                  layout: layout,
                  edges: edges,
                  pathNodeIds: pathNodeIds,
                  focusNodeIds: focusNodeIds,
                  highlightColor: theme.colorScheme.primary,
                ),
              ),
            ),
            ...layout.map((item) {
              final highlighted =
                  highlightedNodeIds.contains(item.node.id) ||
                      pathNodeIds.contains(item.node.id);
              final isEndpoint = pathEndpoints.contains(item.node.id);
              final isDimmed = focusNodeIds.isNotEmpty &&
                  !focusNodeIds.contains(item.node.id) &&
                  !pathNodeIds.contains(item.node.id);
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
                child: Opacity(
                  opacity: isDimmed ? 0.35 : 1,
                  child: _GraphNodeBubble(
                    node: item.node,
                    style: style,
                    onTap: NetworkGraphDisplay.isTappable(item.node)
                        ? onNodeTap
                        : null,
                  ),
                ),
              );
            }),
          ],
        );
      },
    );
  }

  Set<String> _pathEndpointIds() {
    if (pathNodeIds.length < 2) return {};
    return {pathNodeIds.first, pathNodeIds.last};
  }
}

/// Pan / zoom destekli tam ekran grafik alanı. Hem sayfa gövdesinde
/// (varsayılan tam ekran) hem de modal tam ekran görünümünde kullanılır.
class NetworkGraphInteractiveArea extends StatelessWidget {
  const NetworkGraphInteractiveArea({
    super.key,
    required this.nodes,
    required this.edges,
    this.highlightedNodeIds = const {},
    this.pathNodeIds = const [],
    this.focusNodeIds = const {},
    this.onNodeTap,
  });

  final List<GraphNode> nodes;
  final List<GraphEdge> edges;
  final Set<String> highlightedNodeIds;
  final List<String> pathNodeIds;
  final Set<String> focusNodeIds;
  final ValueChanged<GraphNode>? onNodeTap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final base = Size(constraints.maxWidth, constraints.maxHeight);
        final canvas = Size(base.width * 1.4, base.height * 1.4);

        return InteractiveViewer(
          constrained: false,
          minScale: 0.4,
          maxScale: 4,
          boundaryMargin: const EdgeInsets.all(160),
          child: SizedBox(
            width: canvas.width,
            height: canvas.height,
            child: NetworkGraphArea(
              nodes: nodes,
              edges: edges,
              highlightedNodeIds: highlightedNodeIds,
              pathNodeIds: pathNodeIds,
              focusNodeIds: focusNodeIds,
              onNodeTap: onNodeTap,
            ),
          ),
        );
      },
    );
  }
}

class _NetworkGraphFullscreenView extends StatelessWidget {
  const _NetworkGraphFullscreenView({
    required this.nodes,
    required this.edges,
    required this.highlightedNodeIds,
    required this.pathNodeIds,
    this.focusNodeIds = const {},
    this.onNodeTap,
  });

  final List<GraphNode> nodes;
  final List<GraphEdge> edges;
  final Set<String> highlightedNodeIds;
  final List<String> pathNodeIds;
  final Set<String> focusNodeIds;
  final ValueChanged<GraphNode>? onNodeTap;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NetworkGraphCanvasTheme.background(context),
      appBar: CardenceAppBar(
        title: context.l10n.networkGraph,
        leading: CardenceAppBar.iconAction(
          icon: Icons.close_rounded,
          tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          NetworkGraphCanvasBackground(
            child: NetworkGraphInteractiveArea(
              nodes: nodes,
              edges: edges,
              highlightedNodeIds: highlightedNodeIds,
              pathNodeIds: pathNodeIds,
              focusNodeIds: focusNodeIds,
              onNodeTap: onNodeTap,
            ),
          ),
          const Positioned(
            top: 12,
            left: 12,
            child: NetworkGraphCanvasLegend(),
          ),
        ],
      ),
    );
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

  bool get _showAvatar =>
      node.type == GraphNodeType.card || node.type == GraphNodeType.user;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brightness = theme.brightness;

    final isCompany = node.type == GraphNodeType.company ||
        node.type == GraphNodeType.organization;
    final isEvent = node.type == GraphNodeType.event ||
        node.type == GraphNodeType.organizationEvent;

    Widget visual;

    if (isEvent) {
      visual = Transform.rotate(
        angle: math.pi / 4,
        child: Container(
          width: style.size * 0.9,
          height: style.size * 0.9,
          decoration: BoxDecoration(
            color: style.background,
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: style.border,
              width: node.isCenter ? 3 : 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.28),
                blurRadius: 12,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Transform.rotate(
            angle: -math.pi / 4,
            child: Icon(
              style.icon,
              color: style.foreground,
              size: style.size * 0.4,
            ),
          ),
        ),
      );
    } else if (isCompany) {
      visual = Container(
        width: style.size,
        height: style.size,
        decoration: BoxDecoration(
          color: style.background,
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: style.border,
            width: node.isCenter ? 3 : 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.28),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Icon(
          style.icon,
          color: style.foreground,
          size: style.size * 0.4,
        ),
      );
    } else {
      // Person / Card / User (Circular)
      visual = _showAvatar
          ? Container(
              width: style.size,
              height: style.size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: style.border,
                  width: node.isCenter ? 3 : 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.35),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipOval(
                child: ProfileAvatar(
                  photoUrl: node.photoUrl,
                  displayName: NetworkGraphDisplay.nodeLabel(node),
                  size: style.size,
                  circular: true,
                ),
              ),
            )
          : Container(
              width: style.size,
              height: style.size,
              decoration: BoxDecoration(
                color: style.background,
                shape: BoxShape.circle,
                border: Border.all(
                  color: style.border,
                  width: node.isCenter ? 3 : 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.22),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Icon(
                style.icon,
                color: style.foreground,
                size: style.size * 0.4,
              ),
            );
    }

    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        visual,
        const SizedBox(height: 4),
        SizedBox(
          width: style.size + 40,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: NetworkGraphCanvasTheme.nodeLabelBackground(brightness),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: NetworkGraphCanvasTheme.nodeLabelBorder(brightness),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              child: Text(
                NetworkGraphDisplay.nodeLabel(node),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: NetworkGraphCanvasTheme.nodeLabelStyle(
                  theme.textTheme,
                  brightness,
                ),
              ),
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
    this.focusNodeIds = const {},
    required this.highlightColor,
  });

  final List<NetworkGraphLayoutPosition> layout;
  final List<GraphEdge> edges;
  final List<String> pathNodeIds;
  final Set<String> focusNodeIds;
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
      final inFocus = focusNodeIds.isEmpty ||
          (focusNodeIds.contains(edge.source) &&
              focusNodeIds.contains(edge.target));
      final color = onPath ? highlightColor : _colorFor(edge.type);
      final width = onPath
          ? 3.2
          : (1.4 + (edge.weight.clamp(1, 6) * 0.4));
      final alpha = onPath
          ? 1.0
          : inFocus
              ? 0.72
              : 0.18;

      if (onPath) {
        final glow = Paint()
          ..color = color.withValues(alpha: 0.22)
          ..strokeWidth = width + 5
          ..strokeCap = StrokeCap.round
          ..style = PaintingStyle.stroke
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
        _drawCurvedEdge(canvas, source, target, glow);
      }

      final paint = Paint()
        ..color = color.withValues(alpha: alpha)
        ..strokeWidth = width
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;

      _drawCurvedEdge(canvas, source, target, paint);

      if (_isDirectional(edge.type)) {
        final control = _curveControl(source, target);
        _drawArrowHead(
          canvas,
          from: control,
          to: target,
          color: color.withValues(alpha: onPath ? 1 : (inFocus ? 0.85 : 0.25)),
        );
      }
    }
  }

  void _drawCurvedEdge(
    Canvas canvas,
    Offset source,
    Offset target,
    Paint paint,
  ) {
    final control = _curveControl(source, target);
    final path = Path()
      ..moveTo(source.dx, source.dy)
      ..quadraticBezierTo(control.dx, control.dy, target.dx, target.dy);
    canvas.drawPath(path, paint);
  }

  Offset _curveControl(Offset source, Offset target) {
    final mid = Offset(
      (source.dx + target.dx) / 2,
      (source.dy + target.dy) / 2,
    );
    final dx = target.dx - source.dx;
    final dy = target.dy - source.dy;
    final distance = math.sqrt(dx * dx + dy * dy);
    final curve = (distance * 0.12).clamp(0.0, 26.0);
    final normal = distance == 0
        ? Offset.zero
        : Offset(-dy / distance, dx / distance) * curve;
    return mid + normal;
  }

  void _drawArrowHead(
    Canvas canvas, {
    required Offset from,
    required Offset to,
    required Color color,
  }) {
    final angle = math.atan2(to.dy - from.dy, to.dx - from.dx);
    const arrowSize = 8.0;
    // Oku hedef düğümün biraz dışına yerleştir.
    final tip = to - Offset(math.cos(angle), math.sin(angle)) * 22;

    final p1 = tip -
        Offset(
          math.cos(angle - math.pi / 7),
          math.sin(angle - math.pi / 7),
        ) *
            arrowSize;
    final p2 = tip -
        Offset(
          math.cos(angle + math.pi / 7),
          math.sin(angle + math.pi / 7),
        ) *
            arrowSize;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final path = Path()
      ..moveTo(tip.dx, tip.dy)
      ..lineTo(p1.dx, p1.dy)
      ..lineTo(p2.dx, p2.dy)
      ..close();
    canvas.drawPath(path, paint);
  }

  static bool _isDirectional(GraphEdgeType type) {
    return type == GraphEdgeType.owns ||
        type == GraphEdgeType.saved ||
        type == GraphEdgeType.savedBy ||
        type == GraphEdgeType.metAtEvent;
  }

  static Color _colorFor(GraphEdgeType type) {
    switch (type) {
      case GraphEdgeType.owns:
        return AppColors.graphEdgeOwns;
      case GraphEdgeType.saved:
        return AppColors.graphEdgeSaved;
      case GraphEdgeType.savedBy:
        return AppColors.graphEdgeSavedBy;
      case GraphEdgeType.worksAt:
      case GraphEdgeType.sameCompany:
        return AppColors.graphEdgeCompany;
      case GraphEdgeType.metAtEvent:
      case GraphEdgeType.orgEventLink:
        return AppColors.graphEdgeEvent;
      case GraphEdgeType.scanned:
      case GraphEdgeType.viewed:
      case GraphEdgeType.contactClicked:
      case GraphEdgeType.coSaved:
      case GraphEdgeType.assignedLead:
        return AppColors.graphEdgeNeutral;
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
