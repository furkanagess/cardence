import 'package:dio/dio.dart';

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

  void _handleAuthFailure(AuthApiException error) {
    SessionExpiredHandler.instance.handleIfNeeded(error);
  }

  Future<Map<String, dynamic>> get(
    String path, {
    String? accessToken,
    required String fallbackError,
    bool requireData = true,
  }) async {
    try {
      final response = await _dio.get<dynamic>(
        _url(path),
        options: _options(accessToken: accessToken),
      );
      return ApiResponseParser.parseEnvelope(
        response,
        fallbackError,
        requireData: requireData,
      );
    } on AuthApiException catch (e) {
      _handleAuthFailure(e);
      rethrow;
    } on DioException catch (e) {
      final error = ApiResponseParser.fromDioException(e, fallbackError);
      _handleAuthFailure(error);
      throw error;
    }
  }

  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? body,
    String? accessToken,
    required String fallbackError,
    bool requireData = true,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.post<dynamic>(
        _url(path),
        data: body ?? <String, dynamic>{},
        queryParameters: queryParameters,
        options: _options(accessToken: accessToken),
      );
      return ApiResponseParser.parseEnvelope(
        response,
        fallbackError,
        requireData: requireData,
      );
    } on AuthApiException catch (e) {
      _handleAuthFailure(e);
      rethrow;
    } on DioException catch (e) {
      final error = ApiResponseParser.fromDioException(e, fallbackError);
      _handleAuthFailure(error);
      throw error;
    }
  }

  Future<Map<String, dynamic>> put(
    String path, {
    required Map<String, dynamic> body,
    required String accessToken,
    required String fallbackError,
    bool requireData = true,
  }) async {
    try {
      final response = await _dio.put<dynamic>(
        _url(path),
        data: body,
        options: _options(accessToken: accessToken),
      );
      return ApiResponseParser.parseEnvelope(
        response,
        fallbackError,
        requireData: requireData,
      );
    } on AuthApiException catch (e) {
      _handleAuthFailure(e);
      rethrow;
    } on DioException catch (e) {
      final error = ApiResponseParser.fromDioException(e, fallbackError);
      _handleAuthFailure(error);
      throw error;
    }
  }

  Future<Map<String, dynamic>> postMultipart(
    String path, {
    required FormData formData,
    String? accessToken,
    required String fallbackError,
  }) async {
    try {
      final response = await _dio.post<dynamic>(
        _url(path),
        data: formData,
        options: Options(
          headers: {
            if (accessToken != null && accessToken.isNotEmpty)
              'Authorization': 'Bearer $accessToken',
          },
          contentType: 'multipart/form-data',
        ),
      );
      final data = response.data;
      if (data is Map<String, dynamic>) return data;
      if (data is Map) return Map<String, dynamic>.from(data);
      throw AuthApiException(fallbackError);
    } on AuthApiException catch (e) {
      _handleAuthFailure(e);
      rethrow;
    } on DioException catch (e) {
      final error = ApiResponseParser.fromDioException(e, fallbackError);
      _handleAuthFailure(error);
      throw error;
    }
  }

  Future<void> delete(
    String path, {
    required String accessToken,
    required String fallbackError,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.delete<dynamic>(
        _url(path),
        queryParameters: queryParameters,
        options: _options(accessToken: accessToken),
      );
      ApiResponseParser.parseEnvelope(
        response,
        fallbackError,
        requireData: false,
      );
    } on AuthApiException catch (e) {
      _handleAuthFailure(e);
      rethrow;
    } on DioException catch (e) {
      final error = ApiResponseParser.fromDioException(e, fallbackError);
      _handleAuthFailure(error);
      throw error;
    }
  }
}
