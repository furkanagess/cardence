import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

/// Profil fotoğraflarında EXIF yönelimi ve ön kamera ayna düzeltmesi.
class ProfilePhotoNormalizer {
  ProfilePhotoNormalizer._();

  /// Galeri veya kamera seçiminden sonra görüntüyü normalize eder.
  static Future<String> normalizePick(
    String path, {
    bool mirrorFrontCamera = false,
  }) async {
    if (kIsWeb) return path;

    final file = File(path);
    if (!await file.exists()) return path;

    final bytes = await file.readAsBytes();
    final decoded = img.decodeImage(bytes);
    if (decoded == null) return path;

    var corrected = img.bakeOrientation(decoded);
    if (mirrorFrontCamera && Platform.isIOS) {
      corrected = img.flipHorizontal(corrected);
    }

    final tempDir = await getTemporaryDirectory();
    final outPath =
        '${tempDir.path}/profile_photo_${DateTime.now().millisecondsSinceEpoch}.jpg';
    await File(outPath).writeAsBytes(
      img.encodeJpg(corrected, quality: 85),
    );
    return outPath;
  }

  /// Ön kamera ile çekilen görüntüler için geriye dönük kısayol.
  static Future<String> normalizeCameraCapture(String path) =>
      normalizePick(path, mirrorFrontCamera: true);
}
