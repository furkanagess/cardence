import 'dart:typed_data';

import 'package:dio/dio.dart';

import '../auth/auth_token_coordinator.dart';
import 'api_media_urls.dart';

/// `/uploads` altındaki korumalı görselleri Bearer token ile yükler.
///
/// Ana [DioClient] JSON API istekleri içindir; görseller bu sınıftaki ayrı
/// istemci ile `Accept: image/*` başlığıyla alınır.
class AuthenticatedImageLoader {
  AuthenticatedImageLoader._();

  static final Map<String, Uint8List> _memoryCache = {};
  static final Map<String, Future<Uint8List?>> _inFlight = {};
  static Dio? _mediaDio;

  static Dio get _mediaClient => _mediaDio ??= Dio(
        BaseOptions(
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
          headers: const {'Accept': 'image/*'},
          responseType: ResponseType.bytes,
          validateStatus: (status) =>
              status != null && status >= 200 && status < 300,
        ),
      );

  static Uint8List? cachedBytes(String url) {
    final resolved = ApiMediaUrls.resolve(url);
    if (resolved == null) return null;
    return _memoryCache[resolved];
  }

  static bool hasCachedBytes(String url) => cachedBytes(url) != null;

  static Future<Uint8List?> loadBytes(String url) async {
    final resolved = ApiMediaUrls.resolve(url);
    if (resolved == null) return null;

    final cached = _memoryCache[resolved];
    if (cached != null) return cached;

    final inFlight = _inFlight[resolved];
    if (inFlight != null) return inFlight;

    final future = _fetchBytes(resolved);
    _inFlight[resolved] = future;
    try {
      return await future;
    } finally {
      _inFlight.remove(resolved);
    }
  }

  static Future<Uint8List?> _fetchBytes(String resolvedUrl) async {
    final token = await AuthTokenCoordinator.instance?.getValidAccessToken();
    if (token == null || token.isEmpty) return null;

    try {
      final response = await _mediaClient.get<List<int>>(
        resolvedUrl,
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
          followRedirects: true,
        ),
      );
      final data = response.data;
      if (data == null || data.isEmpty) return null;

      final bytes = Uint8List.fromList(data);
      _memoryCache[resolvedUrl] = bytes;
      return bytes;
    } on DioException {
      return null;
    }
  }

  static bool shouldUseAuthenticatedLoader(String? url) =>
      ApiMediaUrls.requiresAuthentication(url);

  static void evict(String url) {
    final resolved = ApiMediaUrls.resolve(url);
    if (resolved == null) return;
    _memoryCache.remove(resolved);
  }

  static void clearCache() => _memoryCache.clear();
}
