import 'dart:convert';

import '../entities/card_share_payload.dart';
import '../../../../core/utils/card_id_generator.dart';

/// Kart paylaşım QR içeriği encode/decode.
class CardShareQrCodec {
  CardShareQrCodec._();

  /// Tarayıcı + sunucu fetch için yeterli minimal QR (`{"id":"..."}`).
  static String encodeCardId(String cardId) {
    final id = cardId.trim();
    return jsonEncode(CardSharePayload(id: id).toJson());
  }

  /// Tam payload (geriye dönük / zengin QR).
  static String encodePayload(CardSharePayload payload) {
    return jsonEncode(payload.toJson());
  }

  /// QR veya metinden 6 haneli cardId çıkarır.
  static String? tryParseCardId(String? raw) {
    final value = raw?.trim();
    if (value == null || value.isEmpty) return null;

    if (CardIdGenerator.isValid(value)) {
      return value;
    }

    final uri = Uri.tryParse(value);
    if (uri != null) {
      final fromQuery = uri.queryParameters['cardId'] ?? uri.queryParameters['id'];
      if (CardIdGenerator.isValid(fromQuery)) {
        return fromQuery!.trim();
      }
      for (final segment in uri.pathSegments.reversed) {
        if (CardIdGenerator.isValid(segment)) {
          return segment.trim();
        }
      }
    }

    try {
      final decoded = jsonDecode(value);
      if (decoded is Map<String, dynamic>) {
        final payload = CardSharePayload.fromJson(decoded);
        if (payload != null && CardIdGenerator.isValid(payload.id)) {
          return payload.id.trim();
        }
      }
    } catch (_) {
      // Düz metin / geçersiz JSON.
    }

    final match = RegExp(r'\d{6}').firstMatch(value);
    final digits = match?.group(0);
    if (CardIdGenerator.isValid(digits)) {
      return digits;
    }

    return null;
  }
}
