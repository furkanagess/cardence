import 'package:flutter/material.dart';

import '../../domain/card_visual_effect.dart';
import '../../l10n/l10n_extensions.dart';
import '../../theme/app_colors.dart';
import '../atoms/custom_button.dart';
import '../../../features/my_cards/presentation/helpers/card_effect_premium_helper.dart';

/// Kart görsel efekt seçimi — yatay kaydırmalı, kompakt.
class CardEffectCustomizeSection extends StatelessWidget {
  const CardEffectCustomizeSection({
    super.key,
    required this.selectedEffect,
    required this.onEffectChanged,
    this.compact = false,
    this.horizontalEdgeInset = 0,
    this.headerPadding,
    this.onUpgradeToPro,
  });

  final CardVisualEffect selectedEffect;
  final ValueChanged<CardVisualEffect> onEffectChanged;
  final bool compact;

  /// Yatay listenin ekran kenarına taşması için üst padding'i nötralize eder.
  final double horizontalEdgeInset;

  /// Başlık ve açıklama satırları için yatay boşluk.
  final EdgeInsetsGeometry? headerPadding;

  /// Pro paywall / yükseltme akışı (onboarding vb.).
  final Future<bool> Function()? onUpgradeToPro;

  String _label(BuildContext context, CardVisualEffect effect) {
    final l10n = context.l10n;
    switch (effect) {
      case CardVisualEffect.none:
        return l10n.efektYok;
      case CardVisualEffect.stars:
        return l10n.efektYildiz;
      case CardVisualEffect.sparkle:
        return l10n.efektParlama;
      case CardVisualEffect.shimmer:
        return l10n.efektShimmer;
      case CardVisualEffect.neon:
        return l10n.efektNeon;
      case CardVisualEffect.glow:
        return l10n.efektIsilti;
      case CardVisualEffect.aurora:
        return l10n.efektAurora;
      case CardVisualEffect.pulse:
        return l10n.efektNabiz;
      case CardVisualEffect.holographic:
        return l10n.efektHolografik;
      case CardVisualEffect.rain:
        return l10n.efektYagmur;
      case CardVisualEffect.snow:
        return l10n.efektKar;
      case CardVisualEffect.fire:
        return l10n.efektAtes;
      case CardVisualEffect.confetti:
        return l10n.efektKonfeti;
      case CardVisualEffect.cosmic:
        return l10n.efektKozmik;
      case CardVisualEffect.ripple:
        return l10n.efektDalga;
      case CardVisualEffect.diamond:
        return l10n.efektElmas;
      case CardVisualEffect.sunset:
        return l10n.efektGunbatimi;
      case CardVisualEffect.frost:
        return l10n.efektBuz;
      case CardVisualEffect.matrix:
        return l10n.efektMatrix;
    }
  }

  Widget _buildEffectList({
    required BuildContext context,
    required double tileHeight,
    required double tileWidth,
  }) {
    Widget listView() {
      return SizedBox(
        height: tileHeight,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.zero,
          itemCount: CardVisualEffect.selectable.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (context, index) {
            final effect = CardVisualEffect.selectable[index];
            final selected = selectedEffect == effect;

            return _EffectTile(
              width: tileWidth,
              label: _label(context, effect),
              icon: _icon(effect),
              selected: selected,
              onTap: () => onEffectChanged(effect),
            );
          },
        ),
      );
    }

    if (horizontalEdgeInset <= 0) return listView();

    final screenWidth = MediaQuery.sizeOf(context).width;

    return Transform.translate(
      offset: Offset(-horizontalEdgeInset, 0),
      child: SizedBox(
        width: screenWidth,
        child: listView(),
      ),
    );
  }

  IconData _icon(CardVisualEffect effect) {
    switch (effect) {
      case CardVisualEffect.none:
        return Icons.block_outlined;
      case CardVisualEffect.stars:
        return Icons.star_outline_rounded;
      case CardVisualEffect.sparkle:
        return Icons.auto_awesome_outlined;
      case CardVisualEffect.shimmer:
        return Icons.waves_outlined;
      case CardVisualEffect.neon:
        return Icons.lightbulb_outline_rounded;
      case CardVisualEffect.glow:
        return Icons.blur_on_rounded;
      case CardVisualEffect.aurora:
        return Icons.gradient_outlined;
      case CardVisualEffect.pulse:
        return Icons.favorite_border_rounded;
      case CardVisualEffect.holographic:
        return Icons.color_lens_outlined;
      case CardVisualEffect.rain:
        return Icons.water_drop_outlined;
      case CardVisualEffect.snow:
        return Icons.ac_unit_rounded;
      case CardVisualEffect.fire:
        return Icons.local_fire_department_outlined;
      case CardVisualEffect.confetti:
        return Icons.celebration_outlined;
      case CardVisualEffect.cosmic:
        return Icons.nightlight_round;
      case CardVisualEffect.ripple:
        return Icons.water_outlined;
      case CardVisualEffect.diamond:
        return Icons.diamond_outlined;
      case CardVisualEffect.sunset:
        return Icons.wb_twilight_outlined;
      case CardVisualEffect.frost:
        return Icons.severe_cold_outlined;
      case CardVisualEffect.matrix:
        return Icons.grid_4x4_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return CardEffectPremiumHelper.build(
      builder: (context, isPremium) {
        final colorScheme = Theme.of(context).colorScheme;
        final textTheme = Theme.of(context).textTheme;
        final tileHeight = compact ? 72.0 : 84.0;
        final tileWidth = compact ? 68.0 : 76.0;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: headerPadding ?? EdgeInsets.zero,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          context.l10n.kartEfekti,
                          style: textTheme.labelMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                      if (!isPremium)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.warning.withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.star_rounded,
                                size: 14,
                                color: AppColors.warning,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                context.l10n.pro,
                                style: textTheme.labelSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.warning,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: compact ? 8 : 12),
            _buildEffectList(
              context: context,
              tileHeight: tileHeight,
              tileWidth: tileWidth,
            ),
            if (!isPremium &&
                CardEffectPremiumHelper.blocksPremiumEffectSelection(
                  effect: selectedEffect,
                  isPremium: isPremium,
                )) ...[
              SizedBox(height: compact ? 8 : 12),
              Padding(
                padding: headerPadding ?? EdgeInsets.zero,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.warning.withValues(alpha: 0.35),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.info_outline_rounded,
                            size: 18,
                            color: AppColors.warning,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              context.l10n.seciliKartEfektiProGerekli,
                              style: textTheme.bodySmall?.copyWith(
                                color: AppColors.warning,
                                fontWeight: FontWeight.w600,
                                height: 1.35,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      CustomButton(
                        label: context.l10n.cardenceProOl,
                        icon: Icons.workspace_premium_rounded,
                        height: 44,
                        onPressed: () => CardEffectPremiumHelper.requestPremiumAccess(
                          context,
                          onRequestPremium: onUpgradeToPro,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

class _EffectTile extends StatelessWidget {
  const _EffectTile({
    required this.width,
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final double width;
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: width,
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
          decoration: BoxDecoration(
            color: selected
                ? colorScheme.primaryContainer
                : colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected
                  ? AppColors.primary.withValues(alpha: 0.45)
                  : colorScheme.outlineVariant.withValues(alpha: 0.45),
              width: selected ? 2 : 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 22,
                color: selected
                    ? AppColors.primary
                    : colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 6),
              Text(
                label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  height: 1.1,
                  fontSize: 10,
                  color: selected
                      ? AppColors.primary
                      : colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
