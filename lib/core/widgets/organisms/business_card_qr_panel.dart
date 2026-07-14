import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../theme/app_colors.dart';
import '../../utils/clipboard_feedback.dart';

/// Kart paylaşım QR paneli — `cardId` içeren QR + kimlik satırı.
class BusinessCardQrPanel extends StatelessWidget {
  const BusinessCardQrPanel({
    super.key,
    required this.qrData,
    required this.cardId,
    this.hint,
    this.size = 200,
  });

  /// QR içeriği (ör. `{"id":"482193"}` veya sadece cardId).
  final String qrData;

  /// Gösterilen / kopyalanabilir kart kimliği.
  final String cardId;

  /// QR altındaki kısa açıklama.
  final String? hint;

  final double size;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final borderColor = isDark ? AppColors.outlineDark : AppColors.outline;
    final secondary = theme.colorScheme.onSurfaceVariant;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor),
            ),
            child: QrImageView(
              data: qrData,
              version: QrVersions.auto,
              size: size,
              backgroundColor: AppColors.surfaceLight,
              eyeStyle: const QrEyeStyle(
                eyeShape: QrEyeShape.square,
                color: AppColors.textPrimary,
              ),
              dataModuleStyle: const QrDataModuleStyle(
                dataModuleShape: QrDataModuleShape.square,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Material(
          color: isDark
              ? AppColors.surfaceVariantDark
              : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            onTap: () => copyTextWithClipboardFeedback(
              context,
              value: cardId,
            ),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  Icon(Icons.tag_rounded, size: 20, color: secondary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      cardId,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  Icon(Icons.copy_rounded, size: 18, color: secondary),
                ],
              ),
            ),
          ),
        ),
        if (hint != null && hint!.trim().isNotEmpty) ...[
          const SizedBox(height: 10),
          Text(
            hint!,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(color: secondary),
          ),
        ],
      ],
    );
  }
}
