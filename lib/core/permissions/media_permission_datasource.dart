import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:permission_handler/permission_handler.dart';

enum MediaPermissionOutcome {
  granted,
  denied,
  permanentlyDenied,
}

/// Kamera ve galeri erişim izinlerini yönetir.
class MediaPermissionDataSource {
  const MediaPermissionDataSource();

  Future<MediaPermissionOutcome> requestCameraAccess() async {
    return _request(Permission.camera);
  }

  /// iOS galeri seçimi öncesi; Android'de sistem seçici genelde izin gerektirmez.
  Future<MediaPermissionOutcome> requestGalleryAccessIfNeeded() async {
    if (kIsWeb || Platform.isAndroid) {
      return MediaPermissionOutcome.granted;
    }
    return _request(Permission.photos);
  }

  Future<bool> openSettings() => openAppSettings();

  Future<MediaPermissionOutcome> _request(Permission permission) async {
    final current = await permission.status;
    if (current.isGranted || current.isLimited) {
      return MediaPermissionOutcome.granted;
    }
    if (current.isPermanentlyDenied) {
      return MediaPermissionOutcome.permanentlyDenied;
    }

    final result = await permission.request();
    if (result.isGranted || result.isLimited) {
      return MediaPermissionOutcome.granted;
    }
    if (result.isPermanentlyDenied) {
      return MediaPermissionOutcome.permanentlyDenied;
    }
    return MediaPermissionOutcome.denied;
  }
}
