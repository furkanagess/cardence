import '../../../../core/network/api_response_parser.dart';
import '../../../../core/network/auth_api_exception.dart';
import '../../../../core/network/dio_api_client.dart';
import '../../domain/entities/graph_scope.dart';
import '../models/network_graph_model.dart';

abstract class NetworkGraphRemoteDataSource {
  Future<NetworkGraphModel> getGraph({
    required String accessToken,
    required GraphScope scope,
    String? eventGroupId,
    String? organizationId,
    String? organizationEventId,
    String? centerCardId,
    int maxDepth = 2,
    int maxNodes = 100,
  });

  Future<NetworkGraphPathModel> getPath({
    required String accessToken,
    required String fromCardId,
    required String toCardId,
    GraphScope scope = GraphScope.personal,
  });
}

class NetworkGraphRemoteDataSourceImpl implements NetworkGraphRemoteDataSource {
  NetworkGraphRemoteDataSourceImpl({DioApiClient? client})
      : _client = client ?? DioApiClient();

  final DioApiClient _client;

  @override
  Future<NetworkGraphModel> getGraph({
    required String accessToken,
    required GraphScope scope,
    String? eventGroupId,
    String? organizationId,
    String? organizationEventId,
    String? centerCardId,
    int maxDepth = 2,
    int maxNodes = 100,
  }) async {
    final json = await _client.get(
      '/NetworkGraph',
      accessToken: accessToken,
      queryParameters: {
        'scope': scope.apiValue,
        if (eventGroupId != null) 'eventGroupId': eventGroupId,
        if (organizationId != null) 'organizationId': organizationId,
        if (organizationEventId != null)
          'organizationEventId': organizationEventId,
        if (centerCardId != null) 'centerCardId': centerCardId,
        'maxDepth': maxDepth,
        'maxNodes': maxNodes,
      },
      fallbackError: 'Ağ grafiği alınamadı.',
    );
    final data = ApiResponseParser.readMap(json['data'] ?? json['Data']);
    if (data == null) {
      throw AuthApiException('Ağ grafiği alınamadı.');
    }

    return NetworkGraphModel.fromJson(data);
  }

  @override
  Future<NetworkGraphPathModel> getPath({
    required String accessToken,
    required String fromCardId,
    required String toCardId,
    GraphScope scope = GraphScope.personal,
  }) async {
    final json = await _client.get(
      '/NetworkGraphPath',
      accessToken: accessToken,
      queryParameters: {
        'fromCardId': fromCardId,
        'toCardId': toCardId,
        'scope': scope.apiValue,
      },
      fallbackError: 'Ağ yolu alınamadı.',
    );
    final data = ApiResponseParser.readMap(json['data'] ?? json['Data']);
    if (data == null) {
      throw AuthApiException('Ağ yolu alınamadı.');
    }

    return NetworkGraphPathModel.fromJson(data);
  }
}
