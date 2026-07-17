import 'package:flutter/material.dart';
import '../../../core/l10n/l10n_extensions.dart';
import 'package:flutter/services.dart';

import '../../utils/card_id_generator.dart';

/// Kart arka yüzü sağ üst: kopyalanabilir Kart ID.
class CardBackIdBadge extends StatelessWidget {
  const CardBackIdBadge({
    super.key,
    required this.cardId,
    required this.onSurface,
    required this.onSurfaceVariant,
    this.scale = 1.0,
  });

  final String? cardId;
  final Color onSurface;
  final Color onSurfaceVariant;

  /// Kart yüzü genişliğine göre ölçek (bkz. CardFaceMetrics).
  final double scale;

  String? get _copyableId {
    final id = cardId?.trim();
    if (id == null || id.isEmpty || !CardIdGenerator.isValid(id)) return null;
    return id;
  }

  Future<void> _copy(BuildContext context, String id) async {
    await Clipboard.setData(ClipboardData(text: id));
    if (!context.mounted) return;
      }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final id = _copyableId;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: id == null ? null : () => _copy(context, id),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 4 * scale,
            vertical: 2 * scale,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                context.l10n.kartId,
                style: textTheme.labelSmall?.copyWith(
                  color: onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.7,
                  fontSize: 9 * scale,
                  height: 1.1,
                ),
              ),
              SizedBox(height: 2 * scale),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    id ?? '------',
                    style: textTheme.labelMedium?.copyWith(
                      color: onSurface,
                      fontWeight: FontWeight.w700,
                      letterSpacing: id != null ? 1.4 : 2,
                      fontSize:
                          (textTheme.labelMedium?.fontSize ?? 12) * scale,
                      fontFeatures: id != null
                          ? const [FontFeature.tabularFigures()]
                          : null,
                      height: 1.1,
                    ),
                  ),
                  if (id != null) ...[
                    SizedBox(width: 4 * scale),
                    Icon(
                      Icons.content_copy_rounded,
                      size: 13 * scale,
                      color: onSurfaceVariant,
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
