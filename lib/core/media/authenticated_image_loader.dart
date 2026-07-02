import 'dart:typed_data';

import 'package:dio/dio.dart';

import '../auth/auth_token_coordinator.dart';
import '../network/dio_client.dart';
import 'api_media_urls.dart';

/// `/uploads` altındaki korumalı görselleri Bearer token ile yükler.
class AuthenticatedImageLoader {
  AuthenticatedImageLoader._();

  static final Map<String, Uint8List> _memoryCache = {};

  static Future<Uint8List?> loadBytes(String url) async {
    final normalized = url.trim();
    if (normalized.isEmpty) return null;

    final cached = _memoryCache[normalized];
    if (cached != null) return cached;

    final token = await AuthTokenCoordinator.instance?.getValidAccessToken();
    if (token == null || token.isEmpty) return null;

    try {
      final response = await DioClient.instance.get<List<int>>(
        normalized,
        options: Options(
          responseType: ResponseType.bytes,
          headers: {'Authorization': 'Bearer $token'},
          followRedirects: true,
          validateStatus: (status) => status != null && status >= 200 && status < 300,
        ),
      );
      final data = response.data;
      if (data == null || data.isEmpty) return null;

      final bytes = Uint8List.fromList(data);
      _memoryCache[normalized] = bytes;
      return bytes;
    } on DioException {
      return null;
    }
  }

  static bool shouldUseAuthenticatedLoader(String? url) =>
      ApiMediaUrls.requiresAuthentication(url);

  static void evict(String url) {
    _memoryCache.remove(url.trim());
  }

  static void clearCache() => _memoryCache.clear();
}
