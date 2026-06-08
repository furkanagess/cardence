import 'dart:convert';

import 'package:dio/dio.dart';

import 'auth_api_exception.dart';

/// Cardence API yanıt zarfı (envelope) ayrıştırma.
class ApiResponseParser {
  ApiResponseParser._();

  static bool readBool(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      final normalized = value.trim().toLowerCase();
      if (normalized == 'true') return true;
      if (normalized == 'false') return false;
    }
    return false;
  }

  static String? readString(dynamic value) {
    if (value is String) {
      final trimmed = value.trim();
      return trimmed.isEmpty ? null : trimmed;
    }
    return null;
  }

  static Map<String, dynamic>? readMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return null;
  }

  static Map<String, dynamic>? extractEntity(Map<String, dynamic> json) {
    final wrapped = readMap(
      json['entity'] ?? json['Entity'] ?? json['data'] ?? json['Data'],
    );
    if (wrapped != null) return wrapped;

    final accessToken = readString(json['accessToken'] ?? json['AccessToken']);
    final userId = readString(json['userId'] ?? json['UserId']);
    if (accessToken != null && userId != null) return json;

    return null;
  }

  static String extractErrorMessage(
    Map<String, dynamic> json,
    String fallbackError,
  ) {
    final direct = readString(json['message'] ?? json['Message']);
    if (direct != null) return direct;

    final error = readMap(json['error'] ?? json['Error']);
    if (error != null) {
      final fromError = readString(
        error['Message'] ??
            error['message'] ??
            error['title'] ??
            error['Title'],
      );
      if (fromError != null) return fromError;
    }

    return fallbackError;
  }

  static String? extractErrorCode(Map<String, dynamic> json) {
    final error = readMap(json['error'] ?? json['Error']);
    if (error == null) return null;
    return readString(error['Code'] ?? error['code']);
  }

  static Map<String, dynamic> _decodeBody(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    if (data is String && data.isNotEmpty) {
      return jsonDecode(data) as Map<String, dynamic>;
    }
    throw AuthApiException('Sunucu yanıtı okunamadı.');
  }

  static Map<String, dynamic> parseEnvelope(
    Response<dynamic> response,
    String fallbackError, {
    bool requireData = true,
  }) {
    final statusCode = response.statusCode ?? 0;

    if (statusCode == 401) {
      throw AuthApiException(
        'Oturum süresi doldu. Lütfen tekrar giriş yapın.',
        statusCode: 401,
      );
    }

    if (statusCode == 204) {
      return const {};
    }

    Map<String, dynamic> json;
    try {
      json = _decodeBody(response.data);
    } catch (_) {
      throw AuthApiException(
        'Sunucu yanıtı okunamadı ($statusCode).',
        statusCode: statusCode,
      );
    }

    final hasSuccessField =
        json.containsKey('success') || json.containsKey('Success');
    final entity = extractEntity(json);
    final data = readMap(json['data'] ?? json['Data']);
    final success = hasSuccessField
        ? readBool(json['success'] ?? json['Success'])
        : entity != null || (!requireData && data != null) || statusCode == 201;

    if (!success) {
      final error = readMap(json['error'] ?? json['Error']);
      int? code;
      String? errorCode;
      if (error != null) {
        final rawCode = error['Code'] ?? error['code'];
        if (rawCode is int) {
          code = rawCode;
        } else if (rawCode is String) {
          errorCode = rawCode;
          code = int.tryParse(rawCode);
        }
      }

      throw AuthApiException(
        extractErrorMessage(json, fallbackError),
        code: code,
        statusCode: statusCode,
        errorCode: errorCode,
      );
    }

    return json;
  }

  static AuthApiException fromDioException(
    DioException exception,
    String fallbackError,
  ) {
    final response = exception.response;
    if (response != null) {
      try {
        parseEnvelope(response, fallbackError);
      } on AuthApiException catch (e) {
        return e;
      }
    }

    return AuthApiException(
      exception.message ?? fallbackError,
      statusCode: response?.statusCode,
    );
  }
}
