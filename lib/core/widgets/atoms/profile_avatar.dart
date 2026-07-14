import 'package:characters/characters.dart';
import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../media/media_image_size.dart';
import 'authenticated_network_image.dart';

/// Profil veya kart fotoğrafı; URL yoksa baş harf gösterir.
class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({
    super.key,
    this.photoUrl,
    this.displayName,
    required this.size,
    this.onTap,
    this.showEditBadge = false,
    this.circular = false,
    this.displaySize,
    this.borderRadius,
  });

  final String? photoUrl;
  final String? displayName;
  final double size;
  final VoidCallback? onTap;
  final bool showEditBadge;
  final bool circular;
  final MediaImageSize? displaySize;
  final BorderRadius? borderRadius;

  MediaImageSize _resolveDisplaySize() =>
      displaySize ??
      (size <= 56
          ? MediaImageSize.thumb
          : size <= 120
              ? MediaImageSize.small
              : size <= 280
                  ? MediaImageSize.medium
                  : MediaImageSize.large);

  String get _initial {
    final name = displayName?.trim();
    if (name == null || name.isEmpty) return '?';
    return name.characters.first.toUpperCase();
  }

  BorderRadius get _borderRadius =>
      borderRadius ?? BorderRadius.circular(circular ? size / 2 : size * 0.28);

  bool get _hasPhoto => photoUrl?.trim().isNotEmpty == true;

  Widget _buildInitial(ColorScheme colorScheme) {
    return Center(
      child: Text(
        _initial,
        style: TextStyle(
          color: AppColors.primary,
          fontWeight: FontWeight.w700,
          fontSize: size * 0.38,
        ),
      ),
    );
  }

  Widget _buildPhoto(ColorScheme colorScheme) {
    final url = photoUrl?.trim();
    if (url == null || url.isEmpty) {
      return _buildInitial(colorScheme);
    }

    return AuthenticatedNetworkImage(
      key: ValueKey('profile-avatar-$url-${_resolveDisplaySize().name}'),
      imageUrl: url,
      width: size,
      height: size,
      fit: BoxFit.cover,
      displaySize: _resolveDisplaySize(),
      errorBuilder: (_) => _buildInitial(colorScheme),
      loadingBuilder: (_) => Center(
        child: SizedBox(
          width: size * 0.34,
          height: size * 0.34,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: colorScheme.primary,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    Widget avatar = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: _hasPhoto
            ? AppColors.surfaceLight
            : colorScheme.primaryContainer,
        borderRadius: _borderRadius,
        border: _hasPhoto
            ? null
            : Border.all(
                color: colorScheme.outline.withValues(alpha: 0.25),
              ),
      ),
      clipBehavior: Clip.antiAlias,
      child: _hasPhoto
          ? SizedBox.expand(child: _buildPhoto(colorScheme))
          : _buildPhoto(colorScheme),
    );

    if (onTap != null) {
      avatar = Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: _borderRadius,
          child: avatar,
        ),
      );
    }

    if (!showEditBadge) return avatar;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        avatar,
        Positioned(
          right: -2,
          bottom: -2,
          child: Container(
            width: size * 0.34,
            height: size * 0.34,
            decoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
              border: Border.all(
                color: colorScheme.surface,
                width: 2,
              ),
            ),
            child: Icon(
              Icons.camera_alt_rounded,
              size: size * 0.18,
              color: AppColors.textOnPrimary,
            ),
          ),
        ),
      ],
    );
  }
}
