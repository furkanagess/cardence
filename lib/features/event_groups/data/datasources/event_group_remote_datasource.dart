import '../../../../core/network/api_response_parser.dart';
import '../../../../core/network/auth_api_exception.dart';
import '../../../../core/network/dio_api_client.dart';
import '../models/event_group_model.dart';

abstract class EventGroupRemoteDataSource {
  Future<List<EventGroupModel>> getEventGroups({required String accessToken});

  Future<EventGroupModel> createEventGroup({
    required String name,
    required String accessToken,
  });

  Future<void> deleteEventGroup({
    required String groupId,
    required String accessToken,
  });

  Future<void> linkCards({
    required String groupId,
    required List<String> cardIds,
    required String accessToken,
  });

  Future<void> unlinkCard({
    required String groupId,
    required String cardId,
    required String accessToken,
  });
}

class EventGroupRemoteDataSourceImpl implements EventGroupRemoteDataSource {
  EventGroupRemoteDataSourceImpl({DioApiClient? client})
      : _client = client ?? DioApiClient();

  final DioApiClient _client;

  List<EventGroupModel> _parseGroupList(Map<String, dynamic> json) {
    final data = json['data'] ?? json['Data'];
    if (data is! List) {
      throw AuthApiException('Etkinlik grupları alınamadı.');
    }

    return data
        .map((item) => EventGroupModel.fromJson(
              Map<String, dynamic>.from(item as Map),
            ))
        .toList();
  }

  EventGroupModel _parseGroup(Map<String, dynamic> json) {
    final data = ApiResponseParser.readMap(json['data'] ?? json['Data']);
    if (data == null) {
      throw AuthApiException('Etkinlik grubu alınamadı.');
    }
    return EventGroupModel.fromJson(data);
  }

  @override
  Future<List<EventGroupModel>> getEventGroups({
    required String accessToken,
  }) async {
    final json = await _client.get(
      '/EventGroups',
      accessToken: accessToken,
      fallbackError: 'Etkinlik grupları alınamadı.',
    );
    return _parseGroupList(json);
  }

  @override
  Future<EventGroupModel> createEventGroup({
    required String name,
    required String accessToken,
  }) async {
    final json = await _client.post(
      '/SaveEventGroup',
      body: {'name': name},
      accessToken: accessToken,
      fallbackError: 'Etkinlik grubu oluşturulamadı.',
    );
    return _parseGroup(json);
  }

  @override
  Future<void> deleteEventGroup({
    required String groupId,
    required String accessToken,
  }) async {
    await _client.delete(
      '/DeleteEventGroup',
      queryParameters: {'id': groupId},
      accessToken: accessToken,
      fallbackError: 'Etkinlik grubu silinemedi.',
    );
  }

  @override
  Future<void> linkCards({
    required String groupId,
    required List<String> cardIds,
    required String accessToken,
  }) async {
    await _client.post(
      '/LinkEventGroupCards',
      body: {
        'id': groupId,
        'cardIds': cardIds,
      },
      accessToken: accessToken,
      fallbackError: 'Kartlar gruba eklenemedi.',
      requireData: false,
    );
  }

  @override
  Future<void> unlinkCard({
    required String groupId,
    required String cardId,
    required String accessToken,
  }) async {
    await _client.delete(
      '/UnlinkEventGroupCard',
      queryParameters: {
        'id': groupId,
        'cardId': cardId,
      },
      accessToken: accessToken,
      fallbackError: 'Kart gruptan çıkarılamadı.',
    );
  }
}
