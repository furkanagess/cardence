import 'dart:io';

import 'package:path_provider/path_provider.dart';

/// Fiziksel kartvizit fotoğraflarını cihazda saklar.
class PhysicalCardImageStore {
  Future<String> persistForCard({
    required String cardId,
    required String sourcePath,
    required bool isFront,
  }) async {
    final dir = await _cardsDir();
    final ext = _extension(sourcePath);
    final fileName = '${cardId}_${isFront ? 'front' : 'back'}.$ext';
    final target = File('${dir.path}/$fileName');
    await File(sourcePath).copy(target.path);
    return target.path;
  }

  Future<Directory> _cardsDir() async {
    final base = await getApplicationDocumentsDirectory();
    final dir = Directory('${base.path}/physical_cards');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  String _extension(String path) {
    final dot = path.lastIndexOf('.');
    if (dot == -1 || dot == path.length - 1) return 'jpg';
    return path.substring(dot + 1).toLowerCase();
  }
}
