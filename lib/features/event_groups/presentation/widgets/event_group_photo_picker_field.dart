import 'dart:io';
import '../../../../core/l10n/l10n_extensions.dart';

import 'package:flutter/material.dart';

import '../../../../core/media/profile_photo_image_picker.dart';
import '../../../../core/theme/app_colors.dart';

/// Opsiyonel etkinlik fotoğrafı seçimi.
class EventGroupPhotoPickerField extends StatelessWidget {
  const EventGroupPhotoPickerField({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final String? value;
  final ValueChanged<String?> onChanged;

  Future<void> _pickPhoto(BuildContext context) async {
    final picker = ProfilePhotoImagePicker();
    final path = await picker.pickImagePath(
      context,
      onError: (message, {bool openSettings = false}) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
    );
    if (path == null) return;
    onChanged(path);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasPhoto = value != null && value!.isNotEmpty;

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
            onTap: () => _pickPhoto(context),
            borderRadius: BorderRadius.circular(14),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: hasPhoto
                        ? Image.file(
                            File(value!),
                            width: 64,
                            height: 64,
                            fit: BoxFit.cover,
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
                      hasPhoto ? 'Fotoğrafı değiştir' : 'Fotoğraf ekle',
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
