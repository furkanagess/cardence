import 'package:permission_handler/permission_handler.dart';

enum CameraPermissionOutcome {
  granted,
  denied,
  permanentlyDenied,
}

/// Kamera erişim iznini yönetir.
class CameraPermissionDataSource {
  Future<CameraPermissionOutcome> readCameraAccess() async {
    final status = await Permission.camera.status;
    if (status.isGranted) {
      return CameraPermissionOutcome.granted;
    }
    if (status.isPermanentlyDenied) {
      return CameraPermissionOutcome.permanentlyDenied;
    }
    return CameraPermissionOutcome.denied;
  }

  Future<CameraPermissionOutcome> requestCameraAccess() async {
    final current = await Permission.camera.status;
    if (current.isGranted) {
      return CameraPermissionOutcome.granted;
    }

    final result = await Permission.camera.request();
    if (result.isGranted) {
      return CameraPermissionOutcome.granted;
    }
    if (result.isPermanentlyDenied) {
      return CameraPermissionOutcome.permanentlyDenied;
    }
    return CameraPermissionOutcome.denied;
  }

  Future<bool> openSettings() => openAppSettings();
}
