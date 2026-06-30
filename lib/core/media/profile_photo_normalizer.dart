import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

/// Kamera ile çekilen profil fotoğraflarında ön kamera ayna etkisini düzeltir.
class ProfilePhotoNormalizer {
  ProfilePhotoNormalizer._();

  /// Ön kamera ile çekilen görüntüler iOS/Android'de aynalı kaydedilebilir.
  /// Kullanıcının çektiği doğal yön korunur; ayna tersi kullanılmaz.
  static Future<String> normalizeCameraCapture(String path) async {
    if (kIsWeb) return path;

    final file = File(path);
    if (!await file.exists()) return path;

    final bytes = await file.readAsBytes();
    final decoded = img.decodeImage(bytes);
    if (decoded == null) return path;

    // EXIF yönelimini piksellere uygula.
    final oriented = img.bakeOrientation(decoded);

    // iOS ön kamera çıktısı aynalı kaydedilir; doğal yöne çevir.
    final corrected =
        Platform.isIOS ? img.flipHorizontal(oriented) : oriented;

    final tempDir = await getTemporaryDirectory();
    final outPath =
        '${tempDir.path}/profile_photo_${DateTime.now().millisecondsSinceEpoch}.jpg';
    await File(outPath).writeAsBytes(
      img.encodeJpg(corrected, quality: 85),
    );
    return outPath;
  }
}
