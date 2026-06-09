import '../../../auth/data/datasources/auth_local_datasource.dart';
import '../../../../core/network/auth_api_exception.dart';
import '../../domain/entities/support_request.dart';
import '../../domain/entities/support_request_result.dart';
import '../../domain/entities/support_topic.dart';
import '../../domain/repositories/support_repository.dart';
import '../datasources/support_remote_datasource.dart';

class SupportRepositoryImpl implements SupportRepository {
  SupportRepositoryImpl({
    required SupportRemoteDataSource remote,
    required AuthLocalDataSource authLocal,
  })  : _remote = remote,
        _authLocal = authLocal;

  final SupportRemoteDataSource _remote;
  final AuthLocalDataSource _authLocal;

  Future<String> _requireAccessToken() async {
    final session = await _authLocal.getSession();
    if (session == null || session.accessToken.isEmpty) {
      throw AuthApiException('Oturum bulunamadı. Lütfen tekrar giriş yapın.');
    }
    return session.accessToken;
  }

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
