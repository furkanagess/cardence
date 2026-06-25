import '../../../../core/auth/auth_token_provider.dart';
import '../../domain/entities/plan_entitlements.dart';
import '../../domain/repositories/plan_repository.dart';
import '../datasources/plan_remote_datasource.dart';

class PlanRepositoryImpl implements PlanRepository {
  const PlanRepositoryImpl({
    required PlanRemoteDataSource remote,
    required AuthTokenProvider authTokens,
  })  : _remote = remote,
        _authTokens = authTokens;

  final PlanRemoteDataSource _remote;
  final AuthTokenProvider _authTokens;

  @override
  Future<PlanEntitlements> getPlanEntitlements() async {
    final token = await _authTokens.requireAccessToken();
    final entitlements = await _remote.getPlanEntitlements(accessToken: token);
    return entitlements.toEntity();
  }
}
