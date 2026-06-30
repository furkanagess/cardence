import '../../../../core/l10n/app_error_keys.dart';
import '../../../../core/network/api_response_parser.dart';
import '../../../../core/network/auth_api_exception.dart';
import '../../../../core/network/dio_api_client.dart';
import '../models/support_request_result_model.dart';

abstract class SupportRemoteDataSource {
  Future<SupportRequestResultModel> submitSupportRequest({
    required Map<String, dynamic> body,
    required String accessToken,
  });
}

class SupportRemoteDataSourceImpl implements SupportRemoteDataSource {
  SupportRemoteDataSourceImpl({DioApiClient? client})
      : _client = client ?? DioApiClient();

  final DioApiClient _client;

  SupportRequestResultModel _parseResult(Map<String, dynamic> json) {
    final data = ApiResponseParser.readMap(json['data'] ?? json['Data']);
    if (data == null) {
      throw AuthApiException(AppErrorKeys.supportRequestFailed);
    }
    return SupportRequestResultModel.fromJson(data);
  }

  @override
  Future<SupportRequestResultModel> submitSupportRequest({
    required Map<String, dynamic> body,
    required String accessToken,
  }) async {
    final json = await _client.post(
      '/SubmitSupportRequest',
      body: body,
      accessToken: accessToken,
      fallbackError: AppErrorKeys.supportRequestFailed,
    );
    return _parseResult(json);
  }
}
