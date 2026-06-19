import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

/// Profil fotoğrafı kaynağı seçimi (kamera veya galeri).
Future<ImageSource?> showProfilePhotoSourceSheet(BuildContext context) {
  return showModalBottomSheet<ImageSource>(
    context: context,
    showDragHandle: true,
    builder: (sheetContext) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_camera_outlined),
                title: const Text('Kamera'),
                onTap: () => Navigator.of(sheetContext).pop(ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text('Galeri'),
                onTap: () => Navigator.of(sheetContext).pop(ImageSource.gallery),
              ),
            ],
          ),
        ),
      );
    },
  );
}
