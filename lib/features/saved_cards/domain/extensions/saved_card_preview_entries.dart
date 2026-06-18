import '../entities/saved_card.dart';

/// Kayıtlı kart önizlemesi için arka yüz girişleri.
extension SavedCardPreviewEntries on SavedCard {
  List<({String label, String value})> get backAboutEntries {
    final text = about?.trim();
    return [
      (
        label: 'Hakkımda',
        value: (text != null && text.isNotEmpty) ? text : '',
      ),
    ];
  }
}
