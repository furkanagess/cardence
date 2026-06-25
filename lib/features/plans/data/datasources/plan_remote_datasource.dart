import '../../../../core/network/api_response_parser.dart';
import '../../../../core/network/auth_api_exception.dart';
import '../../../../core/network/dio_api_client.dart';
import '../models/plan_entitlements_model.dart';

abstract class PlanRemoteDataSource {
  Future<PlanEntitlementsModel> getPlanEntitlements({
    required String accessToken,
  });
}

class PlanRemoteDataSourceImpl implements PlanRemoteDataSource {
  PlanRemoteDataSourceImpl({DioApiClient? client})
      : _client = client ?? DioApiClient();

  final DioApiClient _client;

  @override
  Future<PlanEntitlementsModel> getPlanEntitlements({
    required String accessToken,
  }) async {
    final json = await _client.get(
      '/PlanEntitlements',
      accessToken: accessToken,
      fallbackError: 'Plan bilgileri alınamadı.',
    );
    final data = ApiResponseParser.readMap(json['data'] ?? json['Data']);
    if (data == null) {
      throw AuthApiException('Plan bilgileri alınamadı.');
    }

    return PlanEntitlementsModel.fromJson(data);
  }
}
