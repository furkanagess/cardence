import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/l10n/l10n_extensions.dart';
import '../../../../core/media/profile_photo_image_picker.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/atoms/authenticated_network_image.dart';

enum EventGroupPhotoPickerStyle {
  standard,
  createFlow,
}

/// Opsiyonel etkinlik fotoğrafı seçimi.
class EventGroupPhotoPickerField extends StatelessWidget {
  const EventGroupPhotoPickerField({
    super.key,
    required this.value,
    required this.onChanged,
    this.previewUrl,
    this.style = EventGroupPhotoPickerStyle.standard,
  });

  final String? value;
  final String? previewUrl;
  final ValueChanged<String?> onChanged;
  final EventGroupPhotoPickerStyle style;

  Future<void> _pickPhoto(BuildContext context) async {
    final picker = ProfilePhotoImagePicker();
    final path = await picker.pickImagePath(
      context,
      correctFrontCameraMirror: false,
      preferredCamera: CameraDevice.rear,
      onError: (_, {bool openSettings = false}) {},
    );
    if (path == null) return;
    onChanged(path);
  }

  @override
  Widget build(BuildContext context) {
    if (style == EventGroupPhotoPickerStyle.createFlow) {
      return _CreateFlowEventPhotoPicker(
        value: value,
        previewUrl: previewUrl,
        onChanged: onChanged,
        onPickPhoto: () => _pickPhoto(context),
      );
    }

    return _StandardEventPhotoPicker(
      value: value,
      previewUrl: previewUrl,
      onChanged: onChanged,
      onPickPhoto: () => _pickPhoto(context),
    );
  }
}

class _StandardEventPhotoPicker extends StatelessWidget {
  const _StandardEventPhotoPicker({
    required this.value,
    required this.previewUrl,
    required this.onChanged,
    required this.onPickPhoto,
  });

  final String? value;
  final String? previewUrl;
  final ValueChanged<String?> onChanged;
  final VoidCallback onPickPhoto;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasLocalPhoto = value != null && value!.isNotEmpty;
    final remoteUrl = previewUrl?.trim();
    final hasRemotePhoto =
        !hasLocalPhoto && remoteUrl != null && remoteUrl.isNotEmpty;
    final hasPhoto = hasLocalPhoto || hasRemotePhoto;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          context.l10n.etkinlikFotoraf,
          style: textTheme.labelLarge?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          context.l10n.isteeBalEtkinliiListedeGrsel,
          style: textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
            height: 1.35,
          ),
        ),
        const SizedBox(height: 10),
        Material(
          color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            onTap: onPickPhoto,
            borderRadius: BorderRadius.circular(14),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: hasLocalPhoto
                        ? Image.file(
                            File(value!),
                            width: 64,
                            height: 64,
                            fit: BoxFit.cover,
                          )
                        : hasRemotePhoto
                            ? AuthenticatedNetworkImage(
                                imageUrl: remoteUrl,
                                width: 64,
                                height: 64,
                                fit: BoxFit.cover,
                                errorBuilder: (_) => Container(
                                  width: 64,
                                  height: 64,
                                  color: AppColors.primary.withValues(
                                    alpha: isDark ? 0.22 : 0.1,
                                  ),
                                  child: Icon(
                                    Icons.broken_image_outlined,
                                    color: colorScheme.primary,
                                  ),
                                ),
                              )
                            : Container(
                                width: 64,
                                height: 64,
                                color: AppColors.primary.withValues(
                                  alpha: isDark ? 0.22 : 0.1,
                                ),
                                child: Icon(
                                  Icons.add_photo_alternate_outlined,
                                  color: colorScheme.primary,
                                  size: 28,
                                ),
                              ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      hasPhoto
                          ? context.l10n.eventPhotoChange
                          : context.l10n.eventPhotoAdd,
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                  if (hasPhoto)
                    IconButton(
                      tooltip: context.l10n.fotorafKaldr,
                      onPressed: () => onChanged(null),
                      icon: Icon(
                        Icons.close_rounded,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      visualDensity: VisualDensity.compact,
                    )
                  else
                    Icon(
                      Icons.chevron_right_rounded,
                      color: colorScheme.onSurfaceVariant,
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _CreateFlowEventPhotoPicker extends StatelessWidget {
  const _CreateFlowEventPhotoPicker({
    required this.value,
    required this.previewUrl,
    required this.onChanged,
    required this.onPickPhoto,
  });

  final String? value;
  final String? previewUrl;
  final ValueChanged<String?> onChanged;
  final VoidCallback onPickPhoto;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasLocalPhoto = value != null && value!.isNotEmpty;
    final remoteUrl = previewUrl?.trim();
    final hasRemotePhoto =
        !hasLocalPhoto && remoteUrl != null && remoteUrl.isNotEmpty;
    final hasPhoto = hasLocalPhoto || hasRemotePhoto;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPickPhoto,
        borderRadius: BorderRadius.circular(16),
        child: CustomPaint(
          painter: _EventPhotoDashedBorderPainter(
            color: colorScheme.primary.withValues(alpha: isDark ? 0.65 : 0.55),
            radius: 16,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(
              width: double.infinity,
              height: 196,
              child: hasPhoto
                  ? Stack(
                      fit: StackFit.expand,
                      children: [
                        if (hasLocalPhoto)
                          Image.file(
                            File(value!),
                            fit: BoxFit.cover,
                          )
                        else
                          AuthenticatedNetworkImage(
                            imageUrl: remoteUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_) => _EmptyPhotoUploadContent(
                              colorScheme: colorScheme,
                              textTheme: textTheme,
                              isDark: isDark,
                            ),
                          ),
                        DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.center,
                              colors: [
                                colorScheme.onSurface.withValues(alpha: 0.5),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          left: 14,
                          bottom: 14,
                          child: Text(
                            context.l10n.eventPhotoChange,
                            style: textTheme.titleSmall?.copyWith(
                              color: colorScheme.surface,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        Positioned(
                          top: 10,
                          right: 10,
                          child: Material(
                            color: colorScheme.surface.withValues(alpha: 0.92),
                            shape: const CircleBorder(),
                            clipBehavior: Clip.antiAlias,
                            child: IconButton(
                              tooltip: context.l10n.fotorafKaldr,
                              onPressed: () => onChanged(null),
                              icon: Icon(
                                Icons.close_rounded,
                                color: colorScheme.onSurfaceVariant,
                              ),
                              visualDensity: VisualDensity.compact,
                            ),
                          ),
                        ),
                      ],
                    )
                  : _EmptyPhotoUploadContent(
                      colorScheme: colorScheme,
                      textTheme: textTheme,
                      isDark: isDark,
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyPhotoUploadContent extends StatelessWidget {
  const _EmptyPhotoUploadContent({
    required this.colorScheme,
    required this.textTheme,
    required this.isDark,
  });

  final ColorScheme colorScheme;
  final TextTheme textTheme;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: colorScheme.primary.withValues(alpha: isDark ? 0.2 : 0.1),
            shape: BoxShape.circle,
          ),
          child: SizedBox(
            width: 56,
            height: 56,
            child: Icon(
              Icons.add_a_photo_outlined,
              size: 26,
              color: colorScheme.primary,
            ),
          ),
        ),
        const SizedBox(height: 14),
        Text(
          context.l10n.eventPhotoUpload,
          style: textTheme.titleSmall?.copyWith(
            color: colorScheme.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          context.l10n.eventPhotoFormatHint,
          textAlign: TextAlign.center,
          style: textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
            height: 1.35,
          ),
        ),
      ],
    );
  }
}

class _EventPhotoDashedBorderPainter extends CustomPainter {
  _EventPhotoDashedBorderPainter({
    required this.color,
    required this.radius,
  });

  final Color color;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(1, 1, size.width - 2, size.height - 2),
          Radius.circular(radius),
        ),
      );

    const dashWidth = 7.0;
    const dashSpace = 5.0;
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final end = distance + dashWidth;
        canvas.drawPath(
          metric.extractPath(distance, end.clamp(0, metric.length)),
          paint,
        );
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _EventPhotoDashedBorderPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.radius != radius;
  }
}
