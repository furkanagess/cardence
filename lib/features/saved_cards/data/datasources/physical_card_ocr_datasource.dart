import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

/// Kartvizit fotoğrafından metin çıkarır.
class PhysicalCardOcrDataSource {
  Future<String> recognizeText(String imagePath) async {
    final input = InputImage.fromFilePath(imagePath);
    final recognizer = TextRecognizer(script: TextRecognitionScript.latin);
    try {
      final result = await recognizer.processImage(input);
      return result.text.trim();
    } finally {
      await recognizer.close();
    }
  }
}
