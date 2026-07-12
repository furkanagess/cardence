import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Ekran içinde serbestçe sürüklenebilir FAB alanı.
///
/// [Stack] içinde [Positioned.fill] ile kullanılmalıdır.
class DraggableFab extends StatefulWidget {
  const DraggableFab({
    super.key,
    required this.onPressed,
    required this.builder,
    this.positionStorageKey,
    this.defaultBottomInset = 88,
    this.minBottomInset = 0,
    this.defaultSideInset = 20,
  });

  final VoidCallback onPressed;
  final Widget Function(VoidCallback? onPressed) builder;

  /// Verilirse sürüklenen konum cihazda saklanır.
  final String? positionStorageKey;

  /// İlk konum için alt boşluk (nav bar üstünde başlar).
  final double defaultBottomInset;

  /// FAB'ın alt kenarı ile stack altı arasında kalması gereken minimum boşluk.
  final double minBottomInset;

  /// İlk konum için sağ boşluk.
  final double defaultSideInset;

  /// Ana kabuk liquid bottom nav üstünde FAB için alt boşluk.
  static double mainShellBottomInset(
    BuildContext context, {
    double clearance = 16,
  }) {
    const navBarHeight = 56.0;
    const navBarOuterPadding = 16.0;
    final bottomNavReserve =
        navBarHeight + navBarOuterPadding + MediaQuery.paddingOf(context).bottom;
    return bottomNavReserve + clearance;
  }

  @override
  State<DraggableFab> createState() => _DraggableFabState();
}

class _DraggableFabState extends State<DraggableFab> {
  static const Size _estimatedExtendedSize = Size(168, 56);
  static const double _dragThreshold = 8;

  final GlobalKey _childKey = GlobalKey();

  Offset? _offset;
  Offset _dragAccumulated = Offset.zero;
  bool _isDragging = false;
  Size _childSize = _estimatedExtendedSize;

  @override
  void initState() {
    super.initState();
    _loadStoredPosition();
  }

  Future<void> _loadStoredPosition() async {
    final key = widget.positionStorageKey;
    if (key == null) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final dx = prefs.getDouble('${key}_dx');
      final dy = prefs.getDouble('${key}_dy');
      if (!mounted || dx == null || dy == null) return;
      setState(() => _offset = Offset(dx, dy));
    } catch (_) {}
  }

  Future<void> _persistPosition(Offset offset) async {
    final key = widget.positionStorageKey;
    if (key == null) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('${key}_dx', offset.dx);
      await prefs.setDouble('${key}_dy', offset.dy);
    } catch (_) {}
  }

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

  ({double maxX, double maxY}) _bounds(BoxConstraints constraints) {
    final maxX = (constraints.maxWidth - _childSize.width)
        .clamp(0.0, double.infinity);
    final maxY = (constraints.maxHeight - _childSize.height)
        .clamp(0.0, double.infinity);
    return (maxX: maxX, maxY: maxY);
  }

  Offset _defaultOffset(double maxX, double maxY) {
    return Offset(
      (maxX - widget.defaultSideInset).clamp(0.0, maxX),
      (maxY - widget.defaultBottomInset).clamp(0.0, maxY),
    );
  }

  Offset _clampOffset(Offset position, double maxX, double maxY) {
    final maxTop = (maxY - widget.minBottomInset).clamp(0.0, maxY);
    return Offset(
      position.dx.clamp(0, maxX),
      position.dy.clamp(0, maxTop),
    );
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _measureChild();
    });

    return LayoutBuilder(
      builder: (context, constraints) {
        if (!constraints.hasBoundedHeight || !constraints.hasBoundedWidth) {
          return const SizedBox.shrink();
        }

        final bounds = _bounds(constraints);
        final defaultOffset = _defaultOffset(bounds.maxX, bounds.maxY);
        final position = _offset ?? defaultOffset;
        final clamped = _clampOffset(position, bounds.maxX, bounds.maxY);

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
                    _offset = _clampOffset(next, bounds.maxX, bounds.maxY);
                  });
                },
                onPointerUp: (_) {
                  final current = _offset ?? defaultOffset;
                  final saved = _clampOffset(current, bounds.maxX, bounds.maxY);
                  if (_isDragging) {
                    setState(() => _offset = saved);
                    _persistPosition(saved);
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
