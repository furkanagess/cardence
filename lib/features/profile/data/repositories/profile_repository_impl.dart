import '../../../../core/auth/auth_token_provider.dart';
import '../../domain/entities/profile_stats.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_datasource.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  ProfileRepositoryImpl({
    required ProfileRemoteDataSource remote,
    required AuthTokenProvider authTokens,
  })  : _remote = remote,
        _authTokens = authTokens;

  final ProfileRemoteDataSource _remote;
  final AuthTokenProvider _authTokens;

  Future<String> _requireAccessToken() => _authTokens.requireAccessToken();

  @override
  Future<ProfileStats> getProfileStats() async {
    final token = await _requireAccessToken();
    final model = await _remote.getProfileStats(accessToken: token);
    return model.toEntity();
  }
}
