import '../../../auth/data/datasources/auth_local_datasource.dart';
import '../../../auth/data/datasources/auth_remote_datasource.dart';
import '../../domain/entities/profile_stats.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_datasource.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  ProfileRepositoryImpl({
    required ProfileRemoteDataSource remote,
    required AuthLocalDataSource authLocal,
  })  : _remote = remote,
        _authLocal = authLocal;

  final ProfileRemoteDataSource _remote;
  final AuthLocalDataSource _authLocal;

  Future<String> _requireAccessToken() async {
    final session = await _authLocal.getSession();
    if (session == null || session.accessToken.isEmpty) {
      throw AuthApiException('Oturum bulunamadı. Lütfen tekrar giriş yapın.');
    }
    return session.accessToken;
  }

  @override
  Future<ProfileStats> getProfileStats() async {
    final token = await _requireAccessToken();
    final model = await _remote.getProfileStats(accessToken: token);
    return model.toEntity();
  }
}
