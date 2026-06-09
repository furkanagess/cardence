import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flip_card/flip_card.dart';

/// Fiziksel kartvizit ön/arka fotoğraflarını çevrilebilir önizleme.
class SavedCardsPhysicalPhotoPreview extends StatelessWidget {
  const SavedCardsPhysicalPhotoPreview({
    super.key,
    required this.frontImagePath,
    this.backImagePath,
    this.onTap,
  });

  final String frontImagePath;
  final String? backImagePath;
  final VoidCallback? onTap;

  static const double fixedHeight = 232;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      height: fixedHeight,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: onTap,
              child: FlipCard(
                fill: Fill.fillBack,
                direction: FlipDirection.HORIZONTAL,
                front: _PhotoFace(path: frontImagePath),
                back: backImagePath != null
                    ? _PhotoFace(path: backImagePath!)
                    : _EmptyBackFace(colorScheme: colorScheme),
              ),
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: Icon(
              Icons.flip_camera_android_outlined,
              color: colorScheme.onSurface.withValues(alpha: 0.7),
              size: 20,
            ),
          ),
        ],
      ),
    );
  }
}

class _PhotoFace extends StatelessWidget {
  const _PhotoFace({required this.path});

  final String path;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Image.file(
          File(path),
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          errorBuilder: (_, __, ___) => Center(
            child: Icon(
              Icons.broken_image_outlined,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyBackFace extends StatelessWidget {
  const _EmptyBackFace({required this.colorScheme});

  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Text(
            'Arka yüz fotoğrafı yok',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
          ),
        ),
      ),
    );
  }
}
