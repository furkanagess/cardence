import '../../../../core/auth/auth_token_provider.dart';
import '../../../../core/network/auth_api_exception.dart';
import '../../domain/entities/support_request.dart';
import '../../domain/entities/support_request_result.dart';
import '../../domain/entities/support_topic.dart';
import '../../domain/repositories/support_repository.dart';
import '../datasources/support_remote_datasource.dart';

class SupportRepositoryImpl implements SupportRepository {
  SupportRepositoryImpl({
    required SupportRemoteDataSource remote,
    required AuthTokenProvider authTokens,
  })  : _remote = remote,
        _authTokens = authTokens;

  final SupportRemoteDataSource _remote;
  final AuthTokenProvider _authTokens;

  Future<String> _requireAccessToken() => _authTokens.requireAccessToken();

  @override
  Future<SupportRequestResult> submit(SupportRequest request) async {
    if (!request.isValid) {
      throw AuthApiException(
        'Geçerli bir e-posta ve en az 10 karakterlik bir mesaj girin.',
      );
    }

    final token = await _requireAccessToken();
    final model = await _remote.submitSupportRequest(
      body: {
        'email': request.email.trim(),
        'topic': request.topic.apiValue,
        'message': request.message.trim(),
      },
      accessToken: token,
    );
    return model.toEntity();
  }
}
