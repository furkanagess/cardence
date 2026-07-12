import 'package:dio/dio.dart';

import '../auth/auth_token_coordinator.dart';
import '../auth/session_expired_handler.dart';
import 'api_config.dart';
import 'api_response_parser.dart';
import 'auth_api_exception.dart';
import 'dio_client.dart';

/// Paylaşılan Dio tabanlı API istemcisi.
class DioApiClient {
  DioApiClient({Dio? dio}) : _dio = dio ?? DioClient.instance;

  final Dio _dio;

  String _url(String path) => '${ApiConfig.baseUrl}$path';

  Options _options({String? accessToken}) => Options(
        headers: {
          if (accessToken != null && accessToken.isNotEmpty)
            'Authorization': 'Bearer $accessToken',
        },
      );

  Future<Map<String, dynamic>> get(
    String path, {
    String? accessToken,
    required String fallbackError,
    bool requireData = true,
    Map<String, dynamic>? queryParameters,
  }) {
    return _withAuthRetry(
      (token) async {
        final response = await _dio.get<dynamic>(
          _url(path),
          queryParameters: queryParameters,
          options: _options(accessToken: token),
        );
        return ApiResponseParser.parseEnvelope(
          response,
          fallbackError,
          requireData: requireData,
        );
      },
      accessToken: accessToken,
    );
  }

  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? body,
    String? accessToken,
    required String fallbackError,
    bool requireData = true,
    Map<String, dynamic>? queryParameters,
  }) {
    return _withAuthRetry(
      (token) async {
        final response = await _dio.post<dynamic>(
          _url(path),
          data: body ?? <String, dynamic>{},
          queryParameters: queryParameters,
          options: _options(accessToken: token),
        );
        return ApiResponseParser.parseEnvelope(
          response,
          fallbackError,
          requireData: requireData,
        );
      },
      accessToken: accessToken,
    );
  }

  Future<Map<String, dynamic>> put(
    String path, {
    required Map<String, dynamic> body,
    required String accessToken,
    required String fallbackError,
    bool requireData = true,
  }) {
    return _withAuthRetry(
      (token) async {
        final response = await _dio.put<dynamic>(
          _url(path),
          data: body,
          options: _options(accessToken: token),
        );
        return ApiResponseParser.parseEnvelope(
          response,
          fallbackError,
          requireData: requireData,
        );
      },
      accessToken: accessToken,
    );
  }

  Future<Map<String, dynamic>> postMultipart(
    String path, {
    required FormData formData,
    String? accessToken,
    required String fallbackError,
  }) {
    return _withAuthRetry(
      (token) async {
        final response = await _dio.post<dynamic>(
          _url(path),
          data: formData,
          options: Options(
            headers: {
              if (token != null && token.isNotEmpty)
                'Authorization': 'Bearer $token',
            },
          ),
        );
        return ApiResponseParser.parseEnvelope(response, fallbackError);
      },
      accessToken: accessToken,
    );
  }

  Future<void> delete(
    String path, {
    required String accessToken,
    required String fallbackError,
    Map<String, dynamic>? queryParameters,
  }) {
    return _withAuthRetry(
      (token) async {
        final response = await _dio.delete<dynamic>(
          _url(path),
          queryParameters: queryParameters,
          options: _options(accessToken: token),
        );
        ApiResponseParser.parseEnvelope(
          response,
          fallbackError,
          requireData: false,
        );
      },
      accessToken: accessToken,
    );
  }

  Future<T> _withAuthRetry<T>(
    Future<T> Function(String? token) request, {
    String? accessToken,
  }) async {
    final coordinator = AuthTokenCoordinator.instance;
    var token = accessToken;

    if (token != null && coordinator != null) {
      token = await coordinator.getValidAccessToken() ?? token;
    }

    final attemptedWithAuth = token != null && token.isNotEmpty;

    try {
      return await request(token);
    } on AuthApiException catch (error) {
      if (!_canRetryAuth(error, accessToken, coordinator)) {
        rethrow;
      }

      final outcome = await coordinator!.refreshSession();
      if (!outcome.refreshed) {
        await coordinator.invalidateSession(showDialog: true);
        rethrow;
      }

      final newToken =
          await coordinator.getValidAccessToken(refreshIfStale: false);
      try {
        return await request(newToken);
      } on AuthApiException catch (retryError) {
        if (retryError.isUnauthorized) {
          await coordinator.invalidateSession(showDialog: true);
        }
        rethrow;
      }
    } on DioException catch (error) {
      final parsed = ApiResponseParser.fromDioException(error, 'İşlem başarısız.');
      if (!_canRetryAuth(parsed, accessToken, coordinator)) {
        if (parsed.isUnauthorized && attemptedWithAuth) {
          SessionExpiredHandler.instance.handleIfNeeded(parsed);
        }
        throw parsed;
      }

      final outcome = await coordinator!.refreshSession();
      if (!outcome.refreshed) {
        await coordinator.invalidateSession(showDialog: true);
        throw parsed;
      }

      final newToken =
          await coordinator.getValidAccessToken(refreshIfStale: false);
      try {
        return await request(newToken);
      } on AuthApiException catch (retryError) {
        if (retryError.isUnauthorized) {
          await coordinator.invalidateSession(showDialog: true);
        }
        rethrow;
      } on DioException catch (retryError) {
        throw ApiResponseParser.fromDioException(retryError, 'İşlem başarısız.');
      }
    }
  }

  bool _canRetryAuth(
    AuthApiException error,
    String? accessToken,
    AuthTokenCoordinator? coordinator,
  ) {
    return error.isUnauthorized &&
        accessToken != null &&
        coordinator != null;
  }
}
