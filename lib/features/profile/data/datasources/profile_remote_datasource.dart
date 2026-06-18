import '../../../../core/network/api_response_parser.dart';
import '../../../../core/network/auth_api_exception.dart';
import '../../../../core/network/dio_api_client.dart';
import '../models/profile_stats_model.dart';

abstract class ProfileRemoteDataSource {
  Future<ProfileStatsModel> getProfileStats({required String accessToken});
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  ProfileRemoteDataSourceImpl({DioApiClient? client})
      : _client = client ?? DioApiClient();

  final DioApiClient _client;

  @override
  Future<ProfileStatsModel> getProfileStats({
    required String accessToken,
  }) async {
    final json = await _client.get(
      '/ProfileStats',
      accessToken: accessToken,
      fallbackError: 'Profil istatistikleri alınamadı.',
    );
    final data = ApiResponseParser.readMap(json['data'] ?? json['Data']);
    if (data == null) {
      throw AuthApiException('Profil istatistikleri alınamadı.');
    }
    return ProfileStatsModel.fromJson(data);
  }
}
