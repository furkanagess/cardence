import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';

/// Ekranın sol ortasında sabit: yukarı ok · konum · aşağı ok (ayrı konteynerler).
class SavedCardsFocusArrowTrack extends StatelessWidget {
  const SavedCardsFocusArrowTrack({
    super.key,
    required this.focusedIndex,
    required this.cardCount,
    required this.onFocusedIndexChanged,
  });

  final int focusedIndex;
  final int cardCount;
  final ValueChanged<int> onFocusedIndexChanged;

  static const double width = 40;

  bool get _canGoUp => focusedIndex > 0;
  bool get _canGoDown => cardCount > 0 && focusedIndex < cardCount - 1;

  void _goUp() {
    if (!_canGoUp) return;
    HapticFeedback.selectionClick();
    onFocusedIndexChanged(focusedIndex - 1);
  }

  void _goDown() {
    if (!_canGoDown) return;
    HapticFeedback.selectionClick();
    onFocusedIndexChanged(focusedIndex + 1);
  }

  @override
  Widget build(BuildContext context) {
    if (cardCount <= 1) {
      return const SizedBox.shrink();
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final iconColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;
    final disabledColor =
        isDark ? AppColors.outlineDark : AppColors.outlineVariant;
    final labelColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textDisabled;
    final containerColor = isDark
        ? AppColors.surfaceDark.withValues(alpha: 0.55)
        : AppColors.surfaceLight.withValues(alpha: 0.72);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _ArrowChip(
          icon: Icons.keyboard_arrow_up_rounded,
          enabled: _canGoUp,
          iconColor: iconColor,
          disabledColor: disabledColor,
          containerColor: containerColor,
          onPressed: _goUp,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Text(
            '${focusedIndex + 1}/$cardCount',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: labelColor,
                  fontWeight: FontWeight.w500,
                  fontSize: 11,
                ),
          ),
        ),
        _ArrowChip(
          icon: Icons.keyboard_arrow_down_rounded,
          enabled: _canGoDown,
          iconColor: iconColor,
          disabledColor: disabledColor,
          containerColor: containerColor,
          onPressed: _goDown,
        ),
      ],
    );
  }
}

class _ArrowChip extends StatelessWidget {
  const _ArrowChip({
    required this.icon,
    required this.enabled,
    required this.iconColor,
    required this.disabledColor,
    required this.containerColor,
    required this.onPressed,
  });

  final IconData icon;
  final bool enabled;
  final Color iconColor;
  final Color disabledColor;
  final Color containerColor;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: containerColor,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: (enabled ? iconColor : disabledColor).withValues(alpha: 0.18),
        ),
      ),
      child: InkWell(
        onTap: enabled ? onPressed : null,
        borderRadius: BorderRadius.circular(10),
        child: SizedBox(
          width: SavedCardsFocusArrowTrack.width,
          height: 34,
          child: Icon(
            icon,
            size: 22,
            color: enabled ? iconColor : disabledColor,
          ),
        ),
      ),
    );
  }
}
