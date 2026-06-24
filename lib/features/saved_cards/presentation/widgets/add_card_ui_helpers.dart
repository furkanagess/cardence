import 'dart:io';
import '../../../../core/l10n/l10n_extensions.dart';

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/atoms/custom_button.dart';

/// Kart ekleme alt ekranlarında altta sabit birincil aksiyon.
class AddCardStickyAction extends StatelessWidget {
  const AddCardStickyAction({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.enabled = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          top: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.7)),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
          child: CustomButton(
            label: label,
            icon: icon,
            onPressed: enabled ? onPressed : null,
            enabled: enabled,
            isLoading: isLoading,
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              disabledBackgroundColor: colorScheme.surfaceContainerHighest,
              disabledForegroundColor:
                  colorScheme.onSurface.withValues(alpha: 0.38),
            ),
          ),
        ),
      ),
    );
  }
}

/// Bilgi veya güvenlik kutusu (fotoğraf ipucu, güvenli paylaşım vb.).
class AddCardTipCard extends StatelessWidget {
  const AddCardTipCard.info({
    super.key,
    required this.text,
  })  : title = null,
        isSecurity = false;

  const AddCardTipCard.security({
    super.key,
    required this.title,
    required this.text,
  }) : isSecurity = true;

  final bool isSecurity;
  final String? title;
  final String text;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final isSecurity = this.isSecurity;

    final background = isSecurity
        ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.55)
        : colorScheme.primaryContainer.withValues(alpha: 0.45);
    final iconColor = isSecurity ? AppColors.success : colorScheme.primary;
    final icon = isSecurity
        ? Icons.verified_user_outlined
        : Icons.info_outline_rounded;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSecurity
              ? colorScheme.outlineVariant
              : colorScheme.primaryContainer,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 22, color: iconColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title != null) ...[
                  Text(
                    title!,
                    style: textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                ],
                Text(
                  text,
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AddCardPhotoCaptureZone extends StatelessWidget {
  const AddCardPhotoCaptureZone({
    super.key,
    required this.label,
    required this.hint,
    required this.required,
    required this.onTap,
    this.imagePath,
    this.enabled = true,
  });

  final String label;
  final String hint;
  final bool required;
  final VoidCallback? onTap;
  final String? imagePath;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final hasImage = imagePath != null && imagePath!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Text(
              label,
              style: textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
              ),
            ),
            const Spacer(),
            _CaptureBadge(required: required),
          ],
        ),
        const SizedBox(height: 10),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: enabled ? onTap : null,
            borderRadius: BorderRadius.circular(14),
            child: CustomPaint(
              painter: _DashedBorderPainter(
                color: colorScheme.outline,
                disabledColor: colorScheme.outlineVariant,
                radius: 14,
                enabled: enabled,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: AspectRatio(
                  aspectRatio: 16 / 10,
                  child: hasImage
                      ? Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.file(
                              File(imagePath!),
                              fit: BoxFit.cover,
                            ),
                            DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.center,
                                  colors: [
                                    colorScheme.onSurface.withValues(alpha: 0.55),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            ),
                            Positioned(
                              left: 12,
                              bottom: 12,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.refresh_rounded,
                                    size: 18,
                                    color: colorScheme.surface,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    context.l10n.yenidenek,
                                    style: textTheme.labelLarge?.copyWith(
                                      color: colorScheme.surface,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _CaptureZoneIcon(
                              required: required,
                              enabled: enabled,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              hint,
                              textAlign: TextAlign.center,
                              style: textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _CaptureZoneIcon extends StatelessWidget {
  const _CaptureZoneIcon({
    required this.required,
    required this.enabled,
  });

  final bool required;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final disabledColor = colorScheme.onSurface.withValues(alpha: 0.38);

    if (required) {
      return Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: enabled
              ? colorScheme.primaryContainer.withValues(alpha: 0.85)
              : colorScheme.surfaceContainerHighest,
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.photo_camera_outlined,
          size: 28,
          color: enabled ? colorScheme.primary : disabledColor,
        ),
      );
    }

    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.add_photo_alternate_outlined,
        size: 28,
        color: enabled ? colorScheme.onSurfaceVariant : disabledColor,
      ),
    );
  }
}

class _CaptureBadge extends StatelessWidget {
  const _CaptureBadge({required this.required});

  final bool required;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final color = required ? colorScheme.error : colorScheme.onSurfaceVariant;

    return Text(
      required ? 'ZORUNLU' : 'OPSİYONEL',
      style: textTheme.labelSmall?.copyWith(
        color: color,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.6,
        fontSize: 11,
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  _DashedBorderPainter({
    required this.color,
    required this.disabledColor,
    required this.radius,
    required this.enabled,
  });

  final Color color;
  final Color disabledColor;
  final double radius;
  final bool enabled;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = enabled ? color : disabledColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(1, 1, size.width - 2, size.height - 2),
          Radius.circular(radius),
        ),
      );

    const dashWidth = 7.0;
    const dashSpace = 5.0;
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final end = distance + dashWidth;
        canvas.drawPath(
          metric.extractPath(distance, end.clamp(0, metric.length)),
          paint,
        );
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.disabledColor != disabledColor ||
        oldDelegate.radius != radius ||
        oldDelegate.enabled != enabled;
  }
}
