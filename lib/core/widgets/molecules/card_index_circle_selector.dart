import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/app_colors.dart';

/// Kart slotları için sıralı sayı daireleri (1…[totalSlots]).
///
/// [unlockedCount] kadar slot seçilebilir; kalanlar kilitli görünür ve
/// [onLockedTap] ile paywall vb. tetiklenir.
/// [filledCount] altındaki slotlarda kart vardır; aradaki boş slotlar
/// kilit yerine ekleme göstergesi kullanır.
class CardIndexCircleSelector extends StatelessWidget {
  const CardIndexCircleSelector({
    super.key,
    required this.unlockedCount,
    required this.selectedIndex,
    required this.onSelected,
    this.filledCount,
    this.onLockedTap,
    this.totalSlots = defaultTotalSlots,
    this.axis = Axis.vertical,
    this.size = 32,
    this.selectedSize,
  });

  static const int defaultTotalSlots = 5;
  static const double _defaultSelectedScale = 1.25;

  /// Seçilebilir slot sayısı (dolu + boş).
  final int unlockedCount;

  /// Mevcut kart sayısı; verilmezse [unlockedCount] ile aynı kabul edilir.
  final int? filledCount;

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

  /// Seçili dairenin çapı; verilmezse [size] × 1.25 kullanılır.
  final double? selectedSize;

  double get _resolvedSelectedSize =>
      selectedSize ?? (size * _defaultSelectedScale);

  int get _resolvedFilledCount {
    final filled = filledCount ?? unlockedCount;
    return filled.clamp(0, unlockedCount);
  }

  @override
  Widget build(BuildContext context) {
    if (totalSlots <= 0) return const SizedBox.shrink();

    final resolvedFilledCount = _resolvedFilledCount;

    final children = <Widget>[
      for (var i = 0; i < totalSlots; i++) ...[
        if (i > 0)
          SizedBox(
            width: axis == Axis.horizontal ? 12 : 0,
            height: axis == Axis.vertical ? 12 : 0,
          ),
        _IndexCircle(
          label: '${i + 1}',
          selected: i < unlockedCount && i == selectedIndex,
          locked: i >= unlockedCount,
          empty: i >= resolvedFilledCount && i < unlockedCount,
          size: size,
          selectedSize: _resolvedSelectedSize,
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
        crossAxisAlignment: CrossAxisAlignment.center,
        children: children,
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: children,
    );
  }
}

class _IndexCircle extends StatelessWidget {
  const _IndexCircle({
    required this.label,
    required this.selected,
    required this.locked,
    required this.empty,
    required this.size,
    required this.selectedSize,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final bool locked;
  final bool empty;
  final double size;
  final double selectedSize;
  final VoidCallback onTap;

  double get _circleSize =>
      selected && !locked ? selectedSize : size;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final Color background;
    final Color foreground;
    final Color borderColor;

    if (locked) {
      background = isDark
          ? AppColors.surfaceVariantDark.withValues(alpha: 0.35)
          : AppColors.primaryContainer.withValues(alpha: 0.2);
      foreground = isDark
          ? AppColors.textSecondaryDark.withValues(alpha: 0.55)
          : AppColors.textSecondary.withValues(alpha: 0.45);
      borderColor = isDark
          ? AppColors.outlineDark.withValues(alpha: 0.35)
          : AppColors.outlineVariant.withValues(alpha: 0.55);
    } else if (empty) {
      background = isDark
          ? AppColors.surfaceVariantDark.withValues(alpha: 0.45)
          : AppColors.surfaceLight;
      foreground = isDark
          ? AppColors.textSecondaryDark
          : AppColors.textSecondary;
      borderColor = selected
          ? AppColors.primary
          : (isDark
              ? AppColors.outlineDark.withValues(alpha: 0.45)
              : AppColors.outlineVariant.withValues(alpha: 0.75));
    } else if (selected) {
      background = AppColors.primary;
      foreground = AppColors.textOnPrimary;
      borderColor = AppColors.primaryLight.withValues(alpha: 0.85);
    } else {
      background = isDark
          ? AppColors.primaryContainerDark.withValues(alpha: 0.45)
          : AppColors.primaryContainer.withValues(alpha: 0.55);
      foreground = isDark ? AppColors.textPrimaryDark : AppColors.textSecondary;
      borderColor = isDark
          ? AppColors.outlineDark.withValues(alpha: 0.35)
          : AppColors.primary.withValues(alpha: 0.08);
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          width: _circleSize,
          height: _circleSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: background,
            border: Border.all(
              color: borderColor,
              width: selected && !locked ? 2.5 : 1,
              strokeAlign: BorderSide.strokeAlignInside,
            ),
            boxShadow: selected && !locked
                ? [
                    BoxShadow(
                      color: AppColors.primaryLight.withValues(alpha: 0.45),
                      blurRadius: 0,
                      spreadRadius: 2,
                    ),
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.22),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              if (empty)
                Icon(
                  Icons.add_rounded,
                  size: _circleSize * 0.46,
                  color: selected ? AppColors.primary : foreground,
                )
              else
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: foreground,
                        fontWeight: FontWeight.w800,
                        fontSize: _circleSize * 0.38,
                        height: 1,
                      ),
                ),
              if (locked)
                Positioned(
                  top: -1,
                  right: -1,
                  child: Icon(
                    Icons.lock_rounded,
                    size: _circleSize * 0.34,
                    color: isDark
                        ? AppColors.textSecondaryDark.withValues(alpha: 0.7)
                        : AppColors.textDisabled,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
