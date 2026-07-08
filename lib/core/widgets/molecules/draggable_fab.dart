import 'package:flutter/material.dart';

/// Ekran içinde sürüklenebilir konumlandırılmış FAB alanı.
///
/// [Stack] içinde [Positioned.fill] ile kullanılmalıdır.
class DraggableFab extends StatefulWidget {
  const DraggableFab({
    super.key,
    required this.onPressed,
    required this.builder,
    this.bottomClearance = 72,
    this.margin = 16,
  });

  final VoidCallback onPressed;
  final Widget Function(VoidCallback? onPressed) builder;
  final double bottomClearance;
  final double margin;

  @override
  State<DraggableFab> createState() => _DraggableFabState();
}

class _DraggableFabState extends State<DraggableFab> {
  static const double _fallbackWidth = 56;
  static const double _fallbackHeight = 56;
  static const double _dragThreshold = 8;

  final GlobalKey _childKey = GlobalKey();

  Offset? _offset;
  Offset _dragAccumulated = Offset.zero;
  bool _isDragging = false;
  Size _childSize = const Size(_fallbackWidth, _fallbackHeight);

  void _handlePressed() {
    if (_isDragging) return;
    widget.onPressed();
  }

  void _measureChild() {
    final context = _childKey.currentContext;
    if (context == null) return;
    final box = context.findRenderObject();
    if (box is! RenderBox || !box.hasSize) return;

    final nextSize = box.size;
    if (nextSize == _childSize) return;
    setState(() => _childSize = nextSize);
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _measureChild();
    });

    return LayoutBuilder(
      builder: (context, constraints) {
        final topInset = MediaQuery.paddingOf(context).top;
        final bottomInset =
            MediaQuery.paddingOf(context).bottom + widget.bottomClearance;

        final minX = widget.margin;
        final minY = widget.margin + topInset;
        final maxX =
            (constraints.maxWidth - _childSize.width - widget.margin)
                .clamp(minX, double.infinity);
        final maxY =
            (constraints.maxHeight - _childSize.height - bottomInset -
                    widget.margin)
                .clamp(minY, double.infinity);

        final defaultOffset = Offset(maxX, maxY);
        final position = _offset ?? defaultOffset;

        final clamped = Offset(
          position.dx.clamp(minX, maxX),
          position.dy.clamp(minY, maxY),
        );

        if (_offset != null && _offset != clamped) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            setState(() => _offset = clamped);
          });
        }

        return Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              left: clamped.dx,
              top: clamped.dy,
              child: Listener(
                behavior: HitTestBehavior.translucent,
                onPointerDown: (_) {
                  _dragAccumulated = Offset.zero;
                  _isDragging = false;
                },
                onPointerMove: (event) {
                  _dragAccumulated += event.delta;
                  if (!_isDragging &&
                      _dragAccumulated.distance > _dragThreshold) {
                    _isDragging = true;
                  }
                  if (!_isDragging) return;
                  setState(() {
                    final next = (_offset ?? defaultOffset) + event.delta;
                    _offset = Offset(
                      next.dx.clamp(minX, maxX),
                      next.dy.clamp(minY, maxY),
                    );
                  });
                },
                onPointerUp: (_) {
                  if (_isDragging) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted) setState(() => _isDragging = false);
                    });
                  }
                },
                onPointerCancel: (_) {
                  _isDragging = false;
                  _dragAccumulated = Offset.zero;
                },
                child: KeyedSubtree(
                  key: _childKey,
                  child: widget.builder(_isDragging ? null : _handlePressed),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
