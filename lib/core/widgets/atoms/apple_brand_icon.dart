import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

/// Apple logosu (siluet).
class AppleBrandIcon extends StatelessWidget {
  const AppleBrandIcon({super.key, this.size = 22});

  final double size;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return CustomPaint(
      size: Size.square(size),
      painter: _AppleLogoPainter(
        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
      ),
    );
  }
}

class _AppleLogoPainter extends CustomPainter {
  _AppleLogoPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    final w = size.width;
    final h = size.height;

    // Basitleştirilmiş Apple silueti (ölçeklenmiş).
    path.moveTo(w * 0.52, h * 0.08);
    path.cubicTo(
      w * 0.58, h * 0.02,
      w * 0.68, h * 0.02,
      w * 0.70, h * 0.10,
    );
    path.cubicTo(
      w * 0.62, h * 0.14,
      w * 0.54, h * 0.16,
      w * 0.52, h * 0.08,
    );

    path.moveTo(w * 0.50, h * 0.22);
    path.cubicTo(
      w * 0.68, h * 0.22,
      w * 0.82, h * 0.34,
      w * 0.82, h * 0.56,
    );
    path.cubicTo(
      w * 0.82, h * 0.72,
      w * 0.72, h * 0.92,
      w * 0.58, h * 0.92,
    );
    path.cubicTo(
      w * 0.52, h * 0.92,
      w * 0.48, h * 0.88,
      w * 0.42, h * 0.88,
    );
    path.cubicTo(
      w * 0.36, h * 0.88,
      w * 0.32, h * 0.92,
      w * 0.26, h * 0.92,
    );
    path.cubicTo(
      w * 0.12, h * 0.92,
      w * 0.02, h * 0.74,
      w * 0.02, h * 0.56,
    );
    path.cubicTo(
      w * 0.02, h * 0.36,
      w * 0.16, h * 0.22,
      w * 0.32, h * 0.22,
    );
    path.cubicTo(
      w * 0.38, h * 0.22,
      w * 0.44, h * 0.26,
      w * 0.50, h * 0.22,
    );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _AppleLogoPainter oldDelegate) =>
      oldDelegate.color != color;
}
