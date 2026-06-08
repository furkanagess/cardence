import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Kaydedilen kartlar ekranında sürüklenebilir klasik [FloatingActionButton].
class SavedCardsDraggableFab extends StatefulWidget {
  const SavedCardsDraggableFab({
    super.key,
    required this.canAddMore,
    required this.onPressed,
    this.bottomClearance = 72,
    this.margin = 16,
  });

  final bool canAddMore;
  final VoidCallback onPressed;
  final double bottomClearance;
  final double margin;

  @override
  State<SavedCardsDraggableFab> createState() => _SavedCardsDraggableFabState();
}

class _SavedCardsDraggableFabState extends State<SavedCardsDraggableFab> {
  static const double _fabSize = 56;
  static const double _dragThreshold = 8;

  Offset? _offset;
  Offset _dragAccumulated = Offset.zero;
  bool _isDragging = false;

  void _onFabPressed() {
    if (_isDragging) return;
    widget.onPressed();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final topInset = MediaQuery.paddingOf(context).top;
        final bottomInset =
            MediaQuery.paddingOf(context).bottom + widget.bottomClearance;

        final minX = widget.margin;
        final minY = widget.margin + topInset;
        final maxX = constraints.maxWidth - _fabSize - widget.margin;
        final maxY =
            constraints.maxHeight - _fabSize - bottomInset - widget.margin;

        final defaultOffset = Offset(maxX, maxY);
        final position = _offset ?? defaultOffset;

        final clamped = Offset(
          position.dx.clamp(minX, maxX),
          position.dy.clamp(minY, maxY),
        );

        return Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              left: clamped.dx,
              top: clamped.dy,
              child: Listener(
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
                child: _ClassicFab(
                  canAddMore: widget.canAddMore,
                  onPressed: _onFabPressed,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ClassicFab extends StatelessWidget {
  const _ClassicFab({
    required this.canAddMore,
    required this.onPressed,
  });

  final bool canAddMore;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (canAddMore) {
      return FloatingActionButton(
        heroTag: 'saved_cards_add_fab',
        onPressed: onPressed,
        tooltip: 'Kart ekle',
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        elevation: 4,
        child: const Icon(Icons.add_card_rounded),
      );
    }

    return FloatingActionButton(
      heroTag: 'saved_cards_upgrade_fab',
      onPressed: onPressed,
      tooltip: 'Kapasiteyi artır',
      backgroundColor: colorScheme.surface,
      foregroundColor: colorScheme.primary,
      elevation: 3,
      child: Icon(
        Icons.workspace_premium_outlined,
        color: colorScheme.primary,
      ),
    );
  }
}
