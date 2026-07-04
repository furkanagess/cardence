import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';

/// Odak index'ini değiştiren ok kontrolü.
///
/// [Axis.vertical]: yukarı / aşağı (kaydedilen kartlar yığını).
/// [Axis.horizontal]: sola / sağa (yatay kart şeridi).
class SavedCardsFocusArrowTrack extends StatelessWidget {
  const SavedCardsFocusArrowTrack({
    super.key,
    required this.focusedIndex,
    required this.cardCount,
    required this.onFocusedIndexChanged,
    this.axis = Axis.vertical,
  });

  final int focusedIndex;
  final int cardCount;
  final ValueChanged<int> onFocusedIndexChanged;
  final Axis axis;

  static const double width = 40;

  bool get _canGoPrev => focusedIndex > 0;
  bool get _canGoNext => cardCount > 0 && focusedIndex < cardCount - 1;

  void _goPrev() {
    if (!_canGoPrev) return;
    HapticFeedback.selectionClick();
    onFocusedIndexChanged(focusedIndex - 1);
  }

  void _goNext() {
    if (!_canGoNext) return;
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

    final prevIcon = axis == Axis.vertical
        ? Icons.keyboard_arrow_up_rounded
        : Icons.keyboard_arrow_left_rounded;
    final nextIcon = axis == Axis.vertical
        ? Icons.keyboard_arrow_down_rounded
        : Icons.keyboard_arrow_right_rounded;

    final label = Text(
      '${focusedIndex + 1}/$cardCount',
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: labelColor,
            fontWeight: FontWeight.w500,
            fontSize: 11,
          ),
    );

    final prev = _ArrowChip(
      icon: prevIcon,
      enabled: _canGoPrev,
      iconColor: iconColor,
      disabledColor: disabledColor,
      containerColor: containerColor,
      onPressed: _goPrev,
    );
    final next = _ArrowChip(
      icon: nextIcon,
      enabled: _canGoNext,
      iconColor: iconColor,
      disabledColor: disabledColor,
      containerColor: containerColor,
      onPressed: _goNext,
    );

    if (axis == Axis.horizontal) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          prev,
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: label,
          ),
          next,
        ],
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        prev,
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: label,
        ),
        next,
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
