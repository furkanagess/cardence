import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';

/// Sol kenarda dikey sürüklenebilir ok; [slotCenterYs] ile hizalanan kartı seçer.
class SavedCardsFocusArrowTrack extends StatefulWidget {
  const SavedCardsFocusArrowTrack({
    super.key,
    required this.trackHeight,
    required this.slotCenterYs,
    required this.focusedIndex,
    required this.onFocusedIndexChanged,
  });

  final double trackHeight;
  final List<double> slotCenterYs;
  final int focusedIndex;
  final ValueChanged<int> onFocusedIndexChanged;

  static const double width = 44;

  @override
  State<SavedCardsFocusArrowTrack> createState() =>
      _SavedCardsFocusArrowTrackState();
}

class _SavedCardsFocusArrowTrackState extends State<SavedCardsFocusArrowTrack> {
  double? _dragCenterY;
  int? _lastHapticIndex;

  @override
  void didUpdateWidget(covariant SavedCardsFocusArrowTrack oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_dragCenterY != null &&
        widget.focusedIndex >= 0 &&
        widget.focusedIndex < widget.slotCenterYs.length) {
      _dragCenterY = widget.slotCenterYs[widget.focusedIndex];
    }
  }

  double get _arrowCenterY {
    if (_dragCenterY != null) return _dragCenterY!;
    if (widget.slotCenterYs.isEmpty) return widget.trackHeight / 2;
    final index = widget.focusedIndex.clamp(0, widget.slotCenterYs.length - 1);
    return widget.slotCenterYs[index];
  }

  int _nearestIndex(double localY) {
    if (widget.slotCenterYs.isEmpty) return 0;
    if (widget.slotCenterYs.length == 1) return 0;

    var nearest = 0;
    var minDistance = double.infinity;
    for (var i = 0; i < widget.slotCenterYs.length; i++) {
      final distance = (localY - widget.slotCenterYs[i]).abs();
      if (distance < minDistance) {
        minDistance = distance;
        nearest = i;
      }
    }
    return nearest;
  }

  void _emitFocus(int index) {
    if (index == widget.focusedIndex) return;
    if (_lastHapticIndex != index) {
      _lastHapticIndex = index;
      HapticFeedback.selectionClick();
    }
    widget.onFocusedIndexChanged(index);
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    final localY = details.localPosition.dy.clamp(0.0, widget.trackHeight);
    final index = _nearestIndex(localY);
    setState(() => _dragCenterY = localY);
    _emitFocus(index);
  }

  void _handleDragEnd() {
    final index = widget.focusedIndex.clamp(0, widget.slotCenterYs.length - 1);
    setState(() {
      _dragCenterY = widget.slotCenterYs.isEmpty
          ? null
          : widget.slotCenterYs[index];
    });
    Future<void>.delayed(const Duration(milliseconds: 220), () {
      if (!mounted) return;
      setState(() => _dragCenterY = null);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final trackColor =
        isDark ? AppColors.outlineDark : AppColors.outlineVariant;
    final activeColor =
        isDark ? AppColors.primaryDarkTheme : AppColors.primary;
    final inactiveDotColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textDisabled;

    return SizedBox(
      width: SavedCardsFocusArrowTrack.width,
      height: widget.trackHeight,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: SavedCardsFocusArrowTrack.width / 2 - 0.5,
            top: 12,
            bottom: 12,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: trackColor.withValues(alpha: 0.65),
                borderRadius: BorderRadius.circular(1),
              ),
              child: const SizedBox(width: 1),
            ),
          ),
          for (var i = 0; i < widget.slotCenterYs.length; i++)
            Positioned(
              left: SavedCardsFocusArrowTrack.width / 2 - 3,
              top: widget.slotCenterYs[i] - 3,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOutCubic,
                width: i == widget.focusedIndex ? 8 : 6,
                height: i == widget.focusedIndex ? 8 : 6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: i == widget.focusedIndex ? activeColor : inactiveDotColor,
                  boxShadow: i == widget.focusedIndex
                      ? [
                          BoxShadow(
                            color: activeColor.withValues(alpha: 0.35),
                            blurRadius: 6,
                          ),
                        ]
                      : null,
                ),
              ),
            ),
          AnimatedPositioned(
            duration: _dragCenterY == null
                ? const Duration(milliseconds: 260)
                : Duration.zero,
            curve: Curves.easeOutCubic,
            top: _arrowCenterY - 18,
            left: 0,
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onVerticalDragUpdate: _handleDragUpdate,
              onVerticalDragEnd: (_) => _handleDragEnd(),
              onVerticalDragCancel: _handleDragEnd,
              child: SizedBox(
                width: SavedCardsFocusArrowTrack.width,
                height: 36,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: activeColor,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: activeColor.withValues(alpha: 0.28),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 14,
                    color: AppColors.textOnPrimary,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
