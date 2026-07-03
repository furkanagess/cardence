import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../media/api_media_urls.dart';
import '../../media/authenticated_image_loader.dart';
import '../../media/media_image_size.dart';

/// Cardence API `/uploads` ve harici görselleri yükler.
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
  bool _failed = false;
  bool _usePlainNetwork = false;

  String? get _sourceUrl => widget.imageUrl.trim().isEmpty
      ? null
      : widget.imageUrl.trim();

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

  @override
  void initState() {
    super.initState();
    final requestUrl = _requestUrl;
    if (requestUrl != null) {
      final cached = AuthenticatedImageLoader.cachedBytes(requestUrl);
      if (cached != null) _bytes = cached;
    }
    _load();
  }

  @override
  void didUpdateWidget(covariant AuthenticatedNetworkImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_requestUrl != ApiMediaUrls.variantUrl(
          oldWidget.imageUrl,
          oldWidget.displaySize ??
              _sizeForLayout(oldWidget.width ?? oldWidget.height ?? 128),
        )) {
      _load();
    }
  }

  Future<void> _load() async {
    final source = _sourceUrl;
    final requestUrl = _requestUrl;
    if (source == null || requestUrl == null) {
      if (!mounted) return;
      setState(() {
        _bytes = null;
        _failed = true;
        _usePlainNetwork = false;
      });
      return;
    }

    if (!ApiMediaUrls.isApiUploadUrl(source)) {
      if (!mounted) return;
      setState(() {
        _bytes = null;
        _failed = false;
        _usePlainNetwork = true;
      });
      return;
    }

    final cached = AuthenticatedImageLoader.cachedBytes(requestUrl);
    if (cached != null) {
      if (!mounted) return;
      setState(() {
        _bytes = cached;
        _failed = false;
        _usePlainNetwork = false;
      });
      return;
    }

    if (!mounted) return;
    setState(() {
      _bytes = null;
      _failed = false;
      _usePlainNetwork = false;
    });

    final bytes = await AuthenticatedImageLoader.loadBytes(requestUrl);
    if (!mounted) return;
    setState(() {
      _bytes = bytes;
      _failed = bytes == null;
      _usePlainNetwork = false;
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
    if (source == null || requestUrl == null || _failed) {
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
