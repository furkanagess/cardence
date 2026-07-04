import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../media/api_media_urls.dart';
import '../../media/authenticated_image_loader.dart';
import '../../media/media_image_size.dart';

/// Cardence API `/uploads` ve harici görselleri yükler.
///
/// Bellek/disk önbelleğindeki görselleri senkron gösterir; URL değişse bile
/// yeni baytlar gelene kadar önceki kareyi tutar (gapless).
class AuthenticatedNetworkImage extends StatefulWidget {
  const AuthenticatedNetworkImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.displaySize,
    this.errorBuilder,
    this.loadingBuilder,
  });

  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final MediaImageSize? displaySize;
  final Widget Function(BuildContext context)? errorBuilder;
  final Widget Function(BuildContext context)? loadingBuilder;

  @override
  State<AuthenticatedNetworkImage> createState() =>
      _AuthenticatedNetworkImageState();
}

class _AuthenticatedNetworkImageState extends State<AuthenticatedNetworkImage> {
  Uint8List? _bytes;
  String? _loadedRequestUrl;
  bool _failed = false;
  bool _usePlainNetwork = false;
  bool _showLoading = false;
  int _loadToken = 0;
  Timer? _loadingDelay;

  String? get _sourceUrl =>
      widget.imageUrl.trim().isEmpty ? null : widget.imageUrl.trim();

  MediaImageSize get _resolvedDisplaySize =>
      widget.displaySize ?? _sizeForLayout(widget.width ?? widget.height ?? 128);

  String? get _requestUrl {
    final source = _sourceUrl;
    if (source == null) return null;
    return ApiMediaUrls.variantUrl(source, _resolvedDisplaySize) ??
        ApiMediaUrls.resolve(source);
  }

  static MediaImageSize _sizeForLayout(double layoutPx) {
    if (layoutPx <= 56) return MediaImageSize.thumb;
    if (layoutPx <= 120) return MediaImageSize.small;
    if (layoutPx <= 280) return MediaImageSize.medium;
    return MediaImageSize.large;
  }

  static String? _requestUrlFor(
    String imageUrl,
    MediaImageSize? displaySize,
    double? width,
    double? height,
  ) {
    final source = imageUrl.trim();
    if (source.isEmpty) return null;
    final size = displaySize ?? _sizeForLayout(width ?? height ?? 128);
    return ApiMediaUrls.variantUrl(source, size) ?? ApiMediaUrls.resolve(source);
  }

  @override
  void initState() {
    super.initState();
    _hydrateFromMemoryCache();
    _load();
  }

  @override
  void didUpdateWidget(covariant AuthenticatedNetworkImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldRequestUrl = _requestUrlFor(
      oldWidget.imageUrl,
      oldWidget.displaySize,
      oldWidget.width,
      oldWidget.height,
    );
    if (_requestUrl != oldRequestUrl) {
      _hydrateFromMemoryCache();
      _load();
    }
  }

  @override
  void dispose() {
    _loadingDelay?.cancel();
    super.dispose();
  }

  void _hydrateFromMemoryCache() {
    final requestUrl = _requestUrl;
    if (requestUrl == null) return;
    final cached = AuthenticatedImageLoader.cachedBytes(requestUrl);
    if (cached == null) return;
    _bytes = cached;
    _loadedRequestUrl = requestUrl;
    _failed = false;
    _usePlainNetwork = false;
    _showLoading = false;
  }

  void _scheduleLoadingIndicator() {
    if (_bytes != null || _showLoading) return;
    _loadingDelay?.cancel();
    _loadingDelay = Timer(const Duration(milliseconds: 80), () {
      if (!mounted || _bytes != null || _failed || _usePlainNetwork) return;
      setState(() => _showLoading = true);
    });
  }

  void _cancelLoadingIndicator() {
    _loadingDelay?.cancel();
    _loadingDelay = null;
    _showLoading = false;
  }

  Future<void> _load() async {
    final token = ++_loadToken;
    final source = _sourceUrl;
    final requestUrl = _requestUrl;

    if (source == null || requestUrl == null) {
      if (!mounted || token != _loadToken) return;
      _cancelLoadingIndicator();
      setState(() {
        _bytes = null;
        _loadedRequestUrl = null;
        _failed = true;
        _usePlainNetwork = false;
      });
      return;
    }

    if (!ApiMediaUrls.isApiUploadUrl(source)) {
      if (!mounted || token != _loadToken) return;
      _cancelLoadingIndicator();
      setState(() {
        // Harici URL'lerde önceki API görselini tutma.
        if (_loadedRequestUrl != requestUrl) {
          _bytes = null;
          _loadedRequestUrl = requestUrl;
        }
        _failed = false;
        _usePlainNetwork = true;
      });
      return;
    }

    final cached = AuthenticatedImageLoader.cachedBytes(requestUrl);
    if (cached != null) {
      if (!mounted || token != _loadToken) return;
      _cancelLoadingIndicator();
      setState(() {
        _bytes = cached;
        _loadedRequestUrl = requestUrl;
        _failed = false;
        _usePlainNetwork = false;
      });
      return;
    }

    // Önceki kareyi silme — gapless. Yalnızca hiç görsel yoksa loading planla.
    if (_bytes == null) {
      _scheduleLoadingIndicator();
    } else if (_loadedRequestUrl != requestUrl) {
      // URL değişti; eski kare durur, loading gösterme.
      _cancelLoadingIndicator();
    }

    final bytes = await AuthenticatedImageLoader.loadBytes(requestUrl);
    if (!mounted || token != _loadToken) return;

    _cancelLoadingIndicator();
    setState(() {
      _bytes = bytes;
      _loadedRequestUrl = bytes != null ? requestUrl : _loadedRequestUrl;
      _failed = bytes == null && _bytes == null;
      _usePlainNetwork = false;
      _showLoading = false;
    });
  }

  int? get _cacheSizePx {
    final layout = widget.width ?? widget.height;
    if (layout == null) return _resolvedDisplaySize.width;
    final ratio = MediaQuery.maybeDevicePixelRatioOf(context) ?? 1.0;
    return (layout * ratio).ceil().clamp(1, _resolvedDisplaySize.width);
  }

  @override
  Widget build(BuildContext context) {
    final source = _sourceUrl;
    final requestUrl = _requestUrl;
    if (source == null || requestUrl == null || (_failed && _bytes == null)) {
      return _sized(
        widget.errorBuilder?.call(context) ??
            const ColoredBox(color: Colors.transparent),
      );
    }

    if (_usePlainNetwork) {
      return _sized(
        Image.network(
          ApiMediaUrls.resolve(source) ?? source,
          fit: widget.fit,
          gaplessPlayback: true,
          cacheWidth: _cacheSizePx,
          errorBuilder: (_, __, ___) =>
              widget.errorBuilder?.call(context) ??
              const ColoredBox(color: Colors.transparent),
        ),
      );
    }

    if (_bytes == null) {
      if (!_showLoading) {
        return _sized(const ColoredBox(color: Colors.transparent));
      }
      return _sized(
        widget.loadingBuilder?.call(context) ??
            const Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
      );
    }

    return _sized(
      Image.memory(
        _bytes!,
        fit: widget.fit,
        gaplessPlayback: true,
        cacheWidth: _cacheSizePx,
        errorBuilder: (_, __, ___) =>
            widget.errorBuilder?.call(context) ??
            const ColoredBox(color: Colors.transparent),
      ),
    );
  }

  Widget _sized(Widget child) {
    final width = widget.width;
    final height = widget.height;
    if (width != null || height != null) {
      return SizedBox(width: width, height: height, child: child);
    }
    return child;
  }
}
