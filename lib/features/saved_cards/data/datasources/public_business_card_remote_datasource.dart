import '../../../../core/network/api_response_parser.dart';
import '../../../../core/network/auth_api_exception.dart';
import '../../../../core/network/dio_api_client.dart';
import '../../domain/entities/card_share_payload.dart';

abstract class PublicBusinessCardRemoteDataSource {
  Future<CardSharePayload?> fetchSharePayload(String cardId);

  Future<void> trackContactClick({
    required String cardId,
    required String contactType,
  });
}

class PublicBusinessCardRemoteDataSourceImpl
    implements PublicBusinessCardRemoteDataSource {
  PublicBusinessCardRemoteDataSourceImpl({DioApiClient? client})
      : _client = client ?? DioApiClient();

  final DioApiClient _client;

  @override
  Future<CardSharePayload?> fetchSharePayload(String cardId) async {
    final id = cardId.trim();
    if (id.isEmpty) return null;

    try {
      final json = await _client.get(
        '/PublicBusinessCardShare?cardId=${Uri.encodeQueryComponent(id)}',
        fallbackError: 'Kart bilgisi alınamadı.',
      );
      final data = ApiResponseParser.readMap(json['data'] ?? json['Data']);
      if (data == null) return null;
      return CardSharePayload.fromJson(data);
    } on AuthApiException catch (e) {
      if (e.statusCode == 404) return null;
      rethrow;
    }
  }

  @override
  Future<void> trackContactClick({
    required String cardId,
    required String contactType,
  }) async {
    final id = cardId.trim();
    final type = contactType.trim();
    if (id.isEmpty || type.isEmpty) return;

    try {
      await _client.post(
        '/PublicBusinessCardContactClick',
        queryParameters: {
          'cardId': id,
          'contactType': type,
        },
        fallbackError: 'Etkileşim kaydedilemedi.',
        requireData: false,
      );
    } on AuthApiException catch (e) {
      if (e.statusCode == 404) return;
      rethrow;
    }
  }
}
