import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import '../auth/auth_token_coordinator.dart';
import 'api_media_urls.dart';
import 'media_image_size.dart';

/// Cardence `/uploads` görsellerini yükler; bellek + disk önbelleği kullanır.
class AuthenticatedImageLoader {
  AuthenticatedImageLoader._();

  static final Map<String, Uint8List> _memoryCache = {};
  static final Map<String, Future<Uint8List?>> _inFlight = {};
  static Dio? _mediaDio;
  static Directory? _diskCacheDir;

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

    final diskCached = await _readDiskCache(resolved);
    if (diskCached != null) {
      _memoryCache[resolved] = diskCached;
      return diskCached;
    }

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
      final publicBytes = await _fetchBytes(resolvedUrl);
      if (publicBytes != null) return publicBytes;
    }

    final canonical = ApiMediaUrls.resolve(sourceUrl);
    if (canonical != null && canonical != resolvedUrl) {
      if (token != null && token.isNotEmpty) {
        final fallback = await _fetchBytes(canonical, bearerToken: token);
        if (fallback != null) return fallback;
      }
      if (ApiMediaUrls.isPublicProfilePhotoUrl(sourceUrl)) {
        return _fetchBytes(canonical);
      }
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
      unawaited(_writeDiskCache(resolvedUrl, bytes));
      return bytes;
    } on DioException {
      return null;
    }
  }

  static Future<Directory> _ensureDiskCacheDir() async {
    if (_diskCacheDir != null) return _diskCacheDir!;

    if (kIsWeb) {
      _diskCacheDir = Directory.systemTemp;
      return _diskCacheDir!;
    }

    final root = await getTemporaryDirectory();
    _diskCacheDir = Directory('${root.path}/cardence_media_cache');
    if (!await _diskCacheDir!.exists()) {
      await _diskCacheDir!.create(recursive: true);
    }
    return _diskCacheDir!;
  }

  static String _diskCacheFileName(String url) =>
      url.hashCode.toUnsigned(32).toRadixString(16);

  static Future<Uint8List?> _readDiskCache(String resolvedUrl) async {
    if (kIsWeb) return null;

    try {
      final dir = await _ensureDiskCacheDir();
      final file = File('${dir.path}/${_diskCacheFileName(resolvedUrl)}');
      if (!await file.exists()) return null;
      return file.readAsBytes();
    } catch (_) {
      return null;
    }
  }

  static Future<void> _writeDiskCache(String resolvedUrl, Uint8List bytes) async {
    if (kIsWeb) return;

    try {
      final dir = await _ensureDiskCacheDir();
      final file = File('${dir.path}/${_diskCacheFileName(resolvedUrl)}');
      await file.writeAsBytes(bytes, flush: true);
    } catch (_) {
      // Disk cache is best-effort.
    }
  }

  static void evict(String url) {
    final resolved = ApiMediaUrls.resolve(url);
    if (resolved == null) return;
    _memoryCache.remove(resolved);
    if (!kIsWeb) {
      unawaited(_deleteDiskCache(resolved));
    }
  }

  static void evictAllVariants(String? url) {
    if (url == null || url.trim().isEmpty) return;

    evict(url);
    for (final size in MediaImageSize.values) {
      final variant = ApiMediaUrls.variantUrl(url, size);
      if (variant != null) evict(variant);
    }
  }

  static Future<void> _deleteDiskCache(String resolvedUrl) async {
    try {
      final dir = await _ensureDiskCacheDir();
      final file = File('${dir.path}/${_diskCacheFileName(resolvedUrl)}');
      if (await file.exists()) {
        await file.delete();
      }
    } catch (_) {
      // Ignore disk cache delete failures.
    }
  }

  static void clearCache() {
    _memoryCache.clear();
    if (!kIsWeb && _diskCacheDir != null) {
      final dir = _diskCacheDir;
      _diskCacheDir = null;
      unawaited(dir!.delete(recursive: true));
    }
  }
}
