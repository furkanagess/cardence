import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/atoms/shimmer.dart';
import '../../../../core/widgets/organisms/flippable_person_card.dart';
import 'event_group_detail_header.dart';

/// Etkinlik grubu detay ekranı yüklenirken sayfa düzenine uygun iskelet.
class EventGroupDetailLoadingShimmer extends StatelessWidget {
  const EventGroupDetailLoadingShimmer({super.key});

  static const int _cardPlaceholderCount = 3;
  static const double _deleteBarContentHeight = 48;
  static const double _deleteBarVerticalPadding = 16;

  double _deleteBarInset(BuildContext context) {
    return MediaQuery.paddingOf(context).bottom +
        _deleteBarVerticalPadding +
        _deleteBarContentHeight +
        _deleteBarVerticalPadding;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final coverHeight = eventGroupDetailCoverHeight(context);
    final coverSpacerHeight = coverHeight - eventGroupDetailCoverOverlap;
    final bottomInset = _deleteBarInset(context);

    return Shimmer(
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: coverHeight,
            child: const ShimmerPlaceholder(
              height: double.infinity,
              borderRadius: 0,
            ),
          ),
          CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: SizedBox(height: coverSpacerHeight),
              ),
              SliverToBoxAdapter(
                child: _InfoPanelShimmer(
                  colorScheme: colorScheme,
                  isDark: isDark,
                ),
              ),
              SliverPadding(
                padding: EdgeInsets.fromLTRB(20, 20, 20, bottomInset),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      return Padding(
                        padding: EdgeInsets.only(
                          bottom: index == _cardPlaceholderCount - 1 ? 0 : 20,
                        ),
                        child: _LinkedCardShimmer(index: index),
                      );
                    },
                    childCount: _cardPlaceholderCount,
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            left: 20,
            right: 20,
            bottom: MediaQuery.paddingOf(context).bottom +
                _deleteBarVerticalPadding,
            child: const ShimmerPlaceholder(
              height: _deleteBarContentHeight,
              borderRadius: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoPanelShimmer extends StatelessWidget {
  const _InfoPanelShimmer({
    required this.colorScheme,
    required this.isDark,
  });

  final ColorScheme colorScheme;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: isDark ? 0.06 : 0.04),
                blurRadius: 20,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ShimmerPlaceholder(
                  width: 88,
                  height: 28,
                  borderRadius: 999,
                ),
                const SizedBox(height: 16),
                Row(
                  children: const [
                    ShimmerPlaceholder(
                      width: 168,
                      height: 34,
                      borderRadius: 999,
                    ),
                    SizedBox(width: 8),
                    ShimmerPlaceholder(
                      width: 124,
                      height: 34,
                      borderRadius: 999,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const ShimmerPlaceholder(
                  width: 120,
                  height: 16,
                  borderRadius: 8,
                ),
                const SizedBox(height: 10),
                const ShimmerPlaceholder(
                  height: 14,
                  borderRadius: 8,
                ),
                const SizedBox(height: 8),
                FractionallySizedBox(
                  widthFactor: 0.92,
                  alignment: Alignment.centerLeft,
                  child: const ShimmerPlaceholder(
                    height: 14,
                    borderRadius: 8,
                  ),
                ),
                const SizedBox(height: 8),
                FractionallySizedBox(
                  widthFactor: 0.74,
                  alignment: Alignment.centerLeft,
                  child: const ShimmerPlaceholder(
                    height: 14,
                    borderRadius: 8,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: const [
              ShimmerPlaceholder(
                width: 20,
                height: 20,
                borderRadius: 6,
              ),
              SizedBox(width: 8),
              ShimmerPlaceholder(
                width: 148,
                height: 16,
                borderRadius: 8,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LinkedCardShimmer extends StatelessWidget {
  const _LinkedCardShimmer({required this.index});

  final int index;

  double get _line1WidthFactor => switch (index % 3) {
        0 => 0.72,
        1 => 0.64,
        _ => 0.68,
      };

  double get _line2WidthFactor => switch (index % 3) {
        0 => 0.52,
        1 => 0.46,
        _ => 0.5,
      };

  double get _line3WidthFactor => switch (index % 3) {
        0 => 0.38,
        1 => 0.42,
        _ => 0.36,
      };

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.28),
        ),
      ),
      child: SizedBox(
        height: FlippablePersonCard.fixedHeight,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const ShimmerPlaceholder(
                    width: 48,
                    height: 48,
                    shape: BoxShape.circle,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FractionallySizedBox(
                          widthFactor: 0.62,
                          alignment: Alignment.centerLeft,
                          child: const ShimmerPlaceholder(
                            height: 16,
                            borderRadius: 8,
                          ),
                        ),
                        const SizedBox(height: 8),
                        FractionallySizedBox(
                          widthFactor: 0.44,
                          alignment: Alignment.centerLeft,
                          child: const ShimmerPlaceholder(
                            height: 12,
                            borderRadius: 8,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const ShimmerPlaceholder(
                    width: 28,
                    height: 28,
                    borderRadius: 8,
                  ),
                ],
              ),
              const Spacer(),
              FractionallySizedBox(
                widthFactor: _line1WidthFactor,
                alignment: Alignment.centerLeft,
                child: const ShimmerPlaceholder(height: 12, borderRadius: 8),
              ),
              const SizedBox(height: 10),
              FractionallySizedBox(
                widthFactor: _line2WidthFactor,
                alignment: Alignment.centerLeft,
                child: const ShimmerPlaceholder(height: 12, borderRadius: 8),
              ),
              const SizedBox(height: 10),
              FractionallySizedBox(
                widthFactor: _line3WidthFactor,
                alignment: Alignment.centerLeft,
                child: const ShimmerPlaceholder(height: 12, borderRadius: 8),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
