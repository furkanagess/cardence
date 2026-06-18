import 'package:dio/dio.dart';

import '../../auth/session_expired_handler.dart';
import '../auth_api_exception.dart';

/// 401 yanıtlarında oturum sona erdi diyaloğunu tetikler.
class SessionExpiredInterceptor extends Interceptor {
  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    if (response.statusCode == 401) {
      SessionExpiredHandler.instance.handleIfNeeded(
        AuthApiException(
          'Oturum süresi doldu. Lütfen tekrar giriş yapın.',
          statusCode: 401,
        ),
      );
    }
    handler.next(response);
  }
}
