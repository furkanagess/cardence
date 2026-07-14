import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../../core/l10n/l10n_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/atoms/custom_button.dart';
import '../cubit/scan_physical_card_state.dart';

class ScanCardQrPermissionBody extends StatelessWidget {
  const ScanCardQrPermissionBody({
    super.key,
    required this.status,
    required this.onRequest,
    required this.onOpenSettings,
  });

  final ScanCameraPermissionStatus status;
  final VoidCallback onRequest;
  final Future<bool> Function() onOpenSettings;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = Theme.of(context).colorScheme;
    final permanentlyDenied =
        status == ScanCameraPermissionStatus.permanentlyDenied;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.qr_code_scanner_rounded,
              size: 56,
              color: colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.scanCardQrCameraDenied,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 20),
            CustomButton(
              label: permanentlyDenied
                  ? l10n.ayarlar
                  : l10n.scanCardQrAllowCamera,
              onPressed: permanentlyDenied
                  ? () {
                      onOpenSettings();
                    }
                  : onRequest,
            ),
          ],
        ),
      ),
    );
  }
}

class ScanCardQrScannerBody extends StatelessWidget {
  const ScanCardQrScannerBody({
    super.key,
    required this.controller,
    required this.onDetect,
    this.feedback,
  });

  final MobileScannerController controller;
  final ValueChanged<String?> onDetect;
  final String? feedback;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Stack(
      fit: StackFit.expand,
      children: [
        MobileScanner(
          controller: controller,
          onDetect: (capture) {
            final barcodes = capture.barcodes;
            if (barcodes.isEmpty) return;
            onDetect(barcodes.first.rawValue);
          },
        ),
        const IgnorePointer(
          child: CustomPaint(
            painter: ScanCardQrFramePainter(),
          ),
        ),
        if (feedback != null && feedback!.isNotEmpty)
          Positioned(
            left: 20,
            right: 20,
            bottom: 20,
            child: Material(
              color: colorScheme.surface.withValues(alpha: 0.94),
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                child: Text(
                  feedback!,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.error,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class ScanCardQrFramePainter extends CustomPainter {
  const ScanCardQrFramePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final frameSize = size.shortestSide * 0.62;
    final left = (size.width - frameSize) / 2;
    final top = (size.height - frameSize) / 2;
    final frame = Rect.fromLTWH(left, top, frameSize, frameSize);
    final path = Path()
      ..addRect(Offset.zero & size)
      ..addRRect(RRect.fromRectAndRadius(frame, const Radius.circular(18)))
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(
      path,
      Paint()..color = AppColors.pureBlack.withValues(alpha: 0.45),
    );

    final borderPaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawRRect(
      RRect.fromRectAndRadius(frame, const Radius.circular(18)),
      borderPaint,
    );
  }

  @override
  bool shouldRepaint(covariant ScanCardQrFramePainter oldDelegate) => false;
}
