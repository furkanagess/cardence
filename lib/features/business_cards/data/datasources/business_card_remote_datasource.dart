import '../../../../core/network/api_response_parser.dart';
import '../../../../core/network/auth_api_exception.dart';
import '../../../../core/network/dio_api_client.dart';
import '../models/business_card_model.dart';

abstract class BusinessCardRemoteDataSource {
  Future<List<BusinessCardModel>> getBusinessCards({
    required String accessToken,
  });

  Future<BusinessCardModel> saveBusinessCard(
    Map<String, dynamic> body, {
    required String accessToken,
  });
}

class BusinessCardRemoteDataSourceImpl implements BusinessCardRemoteDataSource {
  BusinessCardRemoteDataSourceImpl({DioApiClient? client})
      : _client = client ?? DioApiClient();

  final DioApiClient _client;

  BusinessCardModel _parseCard(Map<String, dynamic> json) {
    final data = ApiResponseParser.readMap(json['data'] ?? json['Data']);
    if (data == null) {
      throw AuthApiException('Kart bilgisi alınamadı.');
    }
    final card = BusinessCardModel.fromJson(data);
    if (card.cardId == null || card.cardId!.isEmpty) {
      throw AuthApiException('Geçersiz kart yanıtı.');
    }
    return card;
  }

  List<BusinessCardModel> _parseCardList(Map<String, dynamic> json) {
    final data = json['data'] ?? json['Data'];
    if (data is! List) {
      throw AuthApiException('Kartlar alınamadı.');
    }

    return data
        .map((item) => BusinessCardModel.fromJson(
              Map<String, dynamic>.from(item as Map),
            ))
        .toList();
  }

  @override
  Future<List<BusinessCardModel>> getBusinessCards({
    required String accessToken,
  }) async {
    final json = await _client.get(
      '/BusinessCards',
      accessToken: accessToken,
      fallbackError: 'Kartlar alınamadı.',
    );
    return _parseCardList(json);
  }

  @override
  Future<BusinessCardModel> saveBusinessCard(
    Map<String, dynamic> body, {
    required String accessToken,
  }) async {
    final json = await _client.post(
      '/SaveBusinessCard',
      body: body,
      accessToken: accessToken,
      fallbackError: 'Kart kaydedilemedi.',
    );
    return _parseCard(json);
  }
}
