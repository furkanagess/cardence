import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

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
  });

  final String? photoUrl;
  final String? displayName;
  final double size;
  final VoidCallback? onTap;
  final bool showEditBadge;
  final bool circular;

  String get _initial {
    final name = displayName?.trim();
    if (name == null || name.isEmpty) return '?';
    return name[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final url = photoUrl?.trim();

    Widget avatar = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        shape: circular ? BoxShape.circle : BoxShape.rectangle,
        borderRadius:
            circular ? null : BorderRadius.circular(size * 0.28),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.25),
        ),
        image: (url != null && url.isNotEmpty)
            ? DecorationImage(
                image: NetworkImage(url),
                fit: BoxFit.cover,
                onError: (_, __) {},
              )
            : null,
      ),
      alignment: Alignment.center,
      child: (url == null || url.isEmpty)
          ? Text(
              _initial,
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
                fontSize: size * 0.38,
              ),
            )
          : null,
    );

    if (onTap != null) {
      avatar = Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: circular
              ? null
              : BorderRadius.circular(size * 0.28),
          customBorder: circular
              ? const CircleBorder()
              : RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(size * 0.28),
                ),
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
