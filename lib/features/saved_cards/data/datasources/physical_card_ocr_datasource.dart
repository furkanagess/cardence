import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

/// Kartvizit fotoğrafından metin çıkarır.
///
/// Satırları üstten alta sıralayarak parser'ın alan eşlemesini kolaylaştırır.
class PhysicalCardOcrDataSource {
  Future<String> recognizeText(String imagePath) async {
    final input = InputImage.fromFilePath(imagePath);
    final recognizer = TextRecognizer(script: TextRecognitionScript.latin);
    try {
      final result = await recognizer.processImage(input);
      return _orderedText(result);
    } finally {
      await recognizer.close();
    }
  }

  /// Blok/satırları görsel Y konumuna göre sıralar; yoksa ham metni döner.
  static String _orderedText(RecognizedText result) {
    final lines = <({double y, double x, String text})>[];

    for (final block in result.blocks) {
      for (final line in block.lines) {
        final text = line.text.trim();
        if (text.isEmpty) continue;
        final box = line.boundingBox;
        lines.add((
          y: box.top.toDouble(),
          x: box.left.toDouble(),
          text: text,
        ));
      }
    }

    if (lines.isEmpty) {
      return result.text.trim();
    }

    lines.sort((a, b) {
      final dy = a.y.compareTo(b.y);
      if (dy != 0) {
        // Aynı satır bandındaki küçük farkları yok say.
        if ((a.y - b.y).abs() < 12) {
          return a.x.compareTo(b.x);
        }
        return dy;
      }
      return a.x.compareTo(b.x);
    });

    return lines.map((line) => line.text).join('\n').trim();
  }
}
