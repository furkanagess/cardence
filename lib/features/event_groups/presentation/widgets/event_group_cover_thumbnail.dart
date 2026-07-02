import 'dart:io';

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/atoms/authenticated_network_image.dart';

class EventGroupCoverThumbnail extends StatelessWidget {
  const EventGroupCoverThumbnail({
    super.key,
    this.photoUrl,
    this.localFilePath,
    this.size = 44,
    this.borderRadius = 10,
  });

  final String? photoUrl;
  final String? localFilePath;
  final double size;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final localPath = localFilePath?.trim();
    final remoteUrl = photoUrl?.trim();

    Widget child;
    if (localPath != null && localPath.isNotEmpty) {
      child = Image.file(
        File(localPath),
        width: size,
        height: size,
        fit: BoxFit.cover,
      );
    } else if (remoteUrl != null && remoteUrl.isNotEmpty) {
      child = AuthenticatedNetworkImage(
        imageUrl: remoteUrl,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_) => _FallbackIcon(
          size: size,
          colorScheme: colorScheme,
          isDark: isDark,
        ),
        loadingBuilder: (_) => _FallbackIcon(
          size: size,
          colorScheme: colorScheme,
          isDark: isDark,
        ),
      );
    } else {
      return _FallbackIcon(
        size: size,
        colorScheme: colorScheme,
        isDark: isDark,
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: SizedBox(width: size, height: size, child: child),
    );
  }
}

class _FallbackIcon extends StatelessWidget {
  const _FallbackIcon({
    required this.size,
    required this.colorScheme,
    required this.isDark,
  });

  final double size;
  final ColorScheme colorScheme;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: isDark ? 0.22 : 0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(
        Icons.event_rounded,
        size: size * 0.55,
        color: colorScheme.primary,
      ),
    );
  }
}
