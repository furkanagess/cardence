import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'profile_photo_normalizer.dart';
import '../permissions/media_permission_datasource.dart';
import '../widgets/molecules/profile_photo_source_sheet.dart';

typedef ProfilePhotoPickErrorHandler = void Function(
  String message, {
  bool openSettings,
});

/// Profil fotoğrafı seçimi: kaynak seçimi, izin ve image picker.
class ProfilePhotoImagePicker {
  ProfilePhotoImagePicker({
    MediaPermissionDataSource? permissionDataSource,
    ImagePicker? imagePicker,
  })  : _permissionDataSource =
            permissionDataSource ?? const MediaPermissionDataSource(),
        _imagePicker = imagePicker ?? ImagePicker();

  final MediaPermissionDataSource _permissionDataSource;
  final ImagePicker _imagePicker;

  Future<String?> pickImagePath(
    BuildContext context, {
    ProfilePhotoPickErrorHandler? onError,
    bool correctFrontCameraMirror = true,
    CameraDevice preferredCamera = CameraDevice.front,
  }) async {
    final source = await showProfilePhotoSourceSheet(context);
    if (source == null) return null;

    if (source == ImageSource.camera) {
      final outcome = await _permissionDataSource.requestCameraAccess();
      if (outcome != MediaPermissionOutcome.granted) {
        onError?.call(
          outcome == MediaPermissionOutcome.permanentlyDenied
              ? 'Kamera izni kapalı. Ayarlardan izin verip tekrar deneyin.'
              : 'Profil fotoğrafı için kamera izni gerekli.',
          openSettings: outcome == MediaPermissionOutcome.permanentlyDenied,
        );
        return null;
      }
    } else {
      final outcome = await _permissionDataSource.requestGalleryAccessIfNeeded();
      if (outcome != MediaPermissionOutcome.granted) {
        onError?.call(
          outcome == MediaPermissionOutcome.permanentlyDenied
              ? 'Galeri izni kapalı. Ayarlardan izin verip tekrar deneyin.'
              : 'Profil fotoğrafı seçmek için galeri izni gerekli.',
          openSettings: outcome == MediaPermissionOutcome.permanentlyDenied,
        );
        return null;
      }
    }

    try {
      final image = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
        preferredCameraDevice: preferredCamera,
      );
      if (image == null) return null;

      if (source == ImageSource.camera &&
          correctFrontCameraMirror &&
          preferredCamera == CameraDevice.front) {
        return ProfilePhotoNormalizer.normalizePick(
          image.path,
          mirrorFrontCamera: true,
        );
      }
      return ProfilePhotoNormalizer.normalizePick(image.path);
    } catch (_) {
      onError?.call('Fotoğraf seçilemedi. İzinleri kontrol edip tekrar deneyin.');
      return null;
    }
  }
}
