import 'dart:typed_data';

import 'package:dio/dio.dart';

import '../auth/auth_token_coordinator.dart';
import 'api_media_urls.dart';

/// Cardence `/uploads` görsellerini yükler; gerektiğinde Bearer token ekler.
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

    final future = _loadResolved(resolved, url);
    _inFlight[resolved] = future;
    try {
      return await future;
    } finally {
      _inFlight.remove(resolved);
    }
  }

  static Future<Uint8List?> _loadResolved(
    String resolvedUrl,
    String sourceUrl,
  ) async {
    if (!ApiMediaUrls.isApiUploadUrl(sourceUrl)) return null;

    final token =
        await AuthTokenCoordinator.instance?.getValidAccessToken();

    if (token != null && token.isNotEmpty) {
      final authed = await _fetchBytes(resolvedUrl, bearerToken: token);
      if (authed != null) return authed;
    }

    if (ApiMediaUrls.isPublicProfilePhotoUrl(sourceUrl)) {
      return _fetchBytes(resolvedUrl);
    }

    return null;
  }

  static Future<Uint8List?> _fetchBytes(
    String resolvedUrl, {
    String? bearerToken,
  }) async {
    try {
      final headers = <String, String>{};
      if (bearerToken != null && bearerToken.isNotEmpty) {
        headers['Authorization'] = 'Bearer $bearerToken';
      }

      final response = await _mediaClient.get<List<int>>(
        resolvedUrl,
        options: Options(
          headers: headers.isEmpty ? null : headers,
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

  static void evict(String url) {
    final resolved = ApiMediaUrls.resolve(url);
    if (resolved == null) return;
    _memoryCache.remove(resolved);
  }

  static void clearCache() => _memoryCache.clear();
}
