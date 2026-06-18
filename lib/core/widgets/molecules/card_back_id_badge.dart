import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../utils/card_id_generator.dart';

/// Kart arka yüzü sağ üst: kopyalanabilir Kart ID.
class CardBackIdBadge extends StatelessWidget {
  const CardBackIdBadge({
    super.key,
    required this.cardId,
    required this.onSurface,
    required this.onSurfaceVariant,
  });

  final String? cardId;
  final Color onSurface;
  final Color onSurfaceVariant;

  String? get _copyableId {
    final id = cardId?.trim();
    if (id == null || id.isEmpty || !CardIdGenerator.isValid(id)) return null;
    return id;
  }

  Future<void> _copy(BuildContext context, String id) async {
    await Clipboard.setData(ClipboardData(text: id));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('Kart ID kopyalandı: $id'),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
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
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'KART ID',
                style: textTheme.labelSmall?.copyWith(
                  color: onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.7,
                  fontSize: 9,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 2),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    id ?? '------',
                    style: textTheme.labelMedium?.copyWith(
                      color: onSurface,
                      fontWeight: FontWeight.w700,
                      letterSpacing: id != null ? 1.4 : 2,
                      fontFeatures: id != null
                          ? const [FontFeature.tabularFigures()]
                          : null,
                      height: 1.1,
                    ),
                  ),
                  if (id != null) ...[
                    const SizedBox(width: 4),
                    Icon(
                      Icons.content_copy_rounded,
                      size: 13,
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
