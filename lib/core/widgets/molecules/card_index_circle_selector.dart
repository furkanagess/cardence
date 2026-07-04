import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/app_colors.dart';

/// Kart slotları için sıralı sayı daireleri (1…[totalSlots]).
///
/// [unlockedCount] kadar slot seçilebilir; kalanlar kilitli görünür ve
/// [onLockedTap] ile paywall vb. tetiklenir.
class CardIndexCircleSelector extends StatelessWidget {
  const CardIndexCircleSelector({
    super.key,
    required this.unlockedCount,
    required this.selectedIndex,
    required this.onSelected,
    this.onLockedTap,
    this.totalSlots = defaultTotalSlots,
    this.axis = Axis.vertical,
    this.size = 32,
  });

  static const int defaultTotalSlots = 5;

  /// Sahip olunan / açılmış kart sayısı.
  final int unlockedCount;

  /// Seçili kart index'i (yalnızca açık slotlar için anlamlı).
  final int selectedIndex;

  /// Açık bir slota dokunulunca.
  final ValueChanged<int> onSelected;

  /// Kilitli slota dokunulunca (paywall).
  final VoidCallback? onLockedTap;

  /// Toplam gösterilen daire sayısı (varsayılan 5).
  final int totalSlots;

  final Axis axis;
  final double size;

  @override
  Widget build(BuildContext context) {
    if (totalSlots <= 0) return const SizedBox.shrink();

    final children = <Widget>[
      for (var i = 0; i < totalSlots; i++) ...[
        if (i > 0)
          SizedBox(
            width: axis == Axis.horizontal ? 8 : 0,
            height: axis == Axis.vertical ? 8 : 0,
          ),
        _IndexCircle(
          label: '${i + 1}',
          selected: i < unlockedCount && i == selectedIndex,
          locked: i >= unlockedCount,
          size: size,
          onTap: () {
            HapticFeedback.selectionClick();
            if (i >= unlockedCount) {
              onLockedTap?.call();
              return;
            }
            if (i == selectedIndex) return;
            onSelected(i);
          },
        ),
      ],
    ];

    if (axis == Axis.horizontal) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: children,
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: children,
    );
  }
}

class _IndexCircle extends StatelessWidget {
  const _IndexCircle({
    required this.label,
    required this.selected,
    required this.locked,
    required this.size,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final bool locked;
  final double size;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final Color background;
    final Color foreground;
    final Color borderColor;

    if (locked) {
      background = isDark
          ? AppColors.surfaceVariantDark.withValues(alpha: 0.55)
          : colorScheme.surfaceContainerHighest.withValues(alpha: 0.65);
      foreground = isDark
          ? AppColors.textSecondaryDark.withValues(alpha: 0.75)
          : colorScheme.onSurfaceVariant.withValues(alpha: 0.7);
      borderColor = isDark
          ? AppColors.outlineDark.withValues(alpha: 0.4)
          : colorScheme.outlineVariant.withValues(alpha: 0.8);
    } else if (selected) {
      background = AppColors.primary;
      foreground = AppColors.textOnPrimary;
      borderColor = AppColors.primary;
    } else {
      background = isDark
          ? AppColors.surfaceDark.withValues(alpha: 0.9)
          : colorScheme.surface;
      foreground = colorScheme.onSurface;
      borderColor = isDark
          ? AppColors.outlineDark.withValues(alpha: 0.55)
          : colorScheme.outlineVariant;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          width: size,
          height: size,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: background,
            border: Border.all(
              color: borderColor,
              width: selected && !locked ? 0 : 1.5,
            ),
            boxShadow: selected && !locked
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.28),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: locked
              ? Stack(
                  alignment: Alignment.center,
                  children: [
                    Text(
                      label,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: foreground.withValues(alpha: 0.45),
                            fontWeight: FontWeight.w800,
                            fontSize: size * 0.34,
                            height: 1,
                          ),
                    ),
                    Icon(
                      Icons.lock_rounded,
                      size: size * 0.42,
                      color: foreground,
                    ),
                  ],
                )
              : Text(
                  label,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: foreground,
                        fontWeight: FontWeight.w800,
                        fontSize: size * 0.38,
                        height: 1,
                      ),
                ),
        ),
      ),
    );
  }
}
