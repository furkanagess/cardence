import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

/// Google "G" marka ikonu (çok renkli).
class GoogleBrandIcon extends StatelessWidget {
  const GoogleBrandIcon({super.key, this.size = 22});

  final double size;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: _GoogleGPainter(),
    );
  }
}

class _GoogleGPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width * 0.42;

    // Basit dört dilimli "G" — marka renkleriyle daire parçaları.
    paint.color = AppColors.googleBlue;
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: r),
      -0.4,
      1.6,
      true,
      paint,
    );
    paint.color = AppColors.googleGreen;
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: r),
      1.2,
      1.5,
      true,
      paint,
    );
    paint.color = AppColors.googleYellow;
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: r),
      2.7,
      1.2,
      true,
      paint,
    );
    paint.color = AppColors.googleRed;
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: r),
      3.9,
      1.5,
      true,
      paint,
    );

    paint.color = AppColors.surfaceLight;
    canvas.drawCircle(Offset(cx, cy), r * 0.55, paint);

    paint.color = AppColors.googleBlue;
    final bar = RRect.fromRectAndRadius(
      Rect.fromLTWH(cx - r * 0.05, cy - r * 0.18, r * 0.95, r * 0.36),
      const Radius.circular(2),
    );
    canvas.drawRRect(bar, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
