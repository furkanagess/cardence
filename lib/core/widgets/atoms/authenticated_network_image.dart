import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../media/authenticated_image_loader.dart';
import '../../media/api_media_urls.dart';

/// API `/uploads` görselleri için Bearer token ile yükleme yapar.
class AuthenticatedNetworkImage extends StatefulWidget {
  const AuthenticatedNetworkImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.errorBuilder,
    this.loadingBuilder,
  });

  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget Function(BuildContext context)? errorBuilder;
  final Widget Function(BuildContext context)? loadingBuilder;

  @override
  State<AuthenticatedNetworkImage> createState() =>
      _AuthenticatedNetworkImageState();
}

class _AuthenticatedNetworkImageState extends State<AuthenticatedNetworkImage> {
  Uint8List? _bytes;
  bool _failed = false;

  String? get _resolvedUrl => ApiMediaUrls.resolve(widget.imageUrl);

  @override
  void initState() {
    super.initState();
    final cached = AuthenticatedImageLoader.cachedBytes(widget.imageUrl);
    if (cached != null) {
      _bytes = cached;
    }
    _load();
  }

  @override
  void didUpdateWidget(covariant AuthenticatedNetworkImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (ApiMediaUrls.resolve(oldWidget.imageUrl) !=
        ApiMediaUrls.resolve(widget.imageUrl)) {
      _load();
    }
  }

  Future<void> _load() async {
    final url = _resolvedUrl;
    if (url == null || url.isEmpty) {
      if (!mounted) return;
      setState(() {
        _bytes = null;
        _failed = true;
      });
      return;
    }

    if (!AuthenticatedImageLoader.shouldUseAuthenticatedLoader(url)) {
      if (!mounted) return;
      setState(() {
        _bytes = null;
        _failed = false;
      });
      return;
    }

    final cached = AuthenticatedImageLoader.cachedBytes(url);
    if (cached != null) {
      if (!mounted) return;
      setState(() {
        _bytes = cached;
        _failed = false;
      });
      return;
    }

    setState(() {
      _bytes = null;
      _failed = false;
    });

    final bytes = await AuthenticatedImageLoader.loadBytes(url);
    if (!mounted) return;
    setState(() {
      _bytes = bytes;
      _failed = bytes == null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final url = _resolvedUrl;
    if (url == null || url.isEmpty || _failed) {
      return _sized(
        widget.errorBuilder?.call(context) ??
            const ColoredBox(color: Colors.transparent),
      );
    }

    if (!ApiMediaUrls.requiresAuthentication(url)) {
      return _sized(
        Image.network(
          url,
          fit: widget.fit,
          gaplessPlayback: true,
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
