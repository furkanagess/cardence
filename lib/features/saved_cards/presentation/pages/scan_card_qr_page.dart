import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../../core/widgets/atoms/cardence_app_bar.dart';
import '../../../../core/widgets/organisms/cardence_scaffold.dart';
import '../../domain/entities/add_saved_card_result.dart';
import '../../domain/entities/card_share_payload.dart';
import '../../domain/extensions/card_share_payload_to_saved_card.dart';
import '../../domain/usecases/add_saved_card.dart';

/// QR okutarak kart kaydetme ekranı.
class ScanCardQrPage extends StatefulWidget {
  const ScanCardQrPage({
    super.key,
    required this.addSavedCard,
  });

  final AddSavedCard addSavedCard;

  @override
  State<ScanCardQrPage> createState() => _ScanCardQrPageState();
}

class _ScanCardQrPageState extends State<ScanCardQrPage> {
  bool _isProcessing = false;
  late final MobileScannerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = MobileScannerController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_isProcessing) return;
    final barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;
    final code = barcodes.first.rawValue;
    if (code == null || code.isEmpty) return;
    setState(() => _isProcessing = true);
    try {
      final map = jsonDecode(code) as Map<String, dynamic>?;
      final payload = CardSharePayload.fromJson(map);
      if (payload == null) {
        if (!mounted) return;
        _showError('Geçersiz kart kodu.');
        return;
      }
      final result = await widget.addSavedCard(payload.toSavedCard());
      if (!mounted) return;
      switch (result) {
        case AddSavedCardSuccess():
          Navigator.of(context).pop(result);
        case AddSavedCardDuplicate():
          _showError('Bu kart zaten cüzdanınızda.');
        case AddSavedCardLimitReached():
          Navigator.of(context).pop(result);
        case AddSavedCardInvalidPayload(:final message):
          _showError(message);
      }
    } catch (_) {
      if (!mounted) return;
      _showError('QR içeriği okunamadı. Cardence kartı olmayabilir.');
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Widget _buildUnsupportedPlaceholder(BuildContext context) {
    final theme = Theme.of(context);
  final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.qr_code_scanner_rounded,
              size: 64,
              color: colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              'QR tarama yalnızca iOS ve Android uygulamasında kullanılabilir.',
              style: theme.textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            if (kDebugMode) ...[
              const SizedBox(height: 12),
              Text(
                'Simülatörde test için “Kart ID veya kod yapıştır” seçeneğini kullanın.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (kIsWeb) {
      return CardenceScaffold(
        appBar: const CardenceAppBar(title: 'QR ile kart al'),
        body: _buildUnsupportedPlaceholder(context),
      );
    }

    return CardenceScaffold(
      appBar: const CardenceAppBar(title: 'QR ile kart al'),
      body: Stack(
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
            errorBuilder: (context, error, child) =>
                _buildUnsupportedPlaceholder(context),
          ),
          Positioned(
            left: 20,
            right: 20,
            bottom: 32,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: colorScheme.inverseSurface.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Text(
                  'Cardence kart QR kodunu çerçeveye hizalayın',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onInverseSurface,
                      ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
          if (_isProcessing)
            ColoredBox(
              color: colorScheme.scrim.withValues(alpha: 0.45),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}
