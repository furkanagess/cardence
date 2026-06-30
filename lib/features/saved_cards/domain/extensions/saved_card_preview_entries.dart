import '../entities/saved_card.dart';

/// Kayıtlı kart önizlemesi için arka yüz girişleri.
extension SavedCardPreviewEntries on SavedCard {
  bool get hasAboutContent {
    final about = this.about?.trim();
    return about != null && about.isNotEmpty;
  }

  List<({String label, String value})> get backAboutEntries {
    final items = <({String label, String value})>[];
    final about = this.about?.trim();
    if (about != null && about.isNotEmpty) {
      items.add((label: 'Hakkımda', value: about));
    }

    final skills = this.skills?.trim();
    if (skills != null && skills.isNotEmpty) {
      items.add((label: 'Yetenekler', value: skills));
    }

    return items;
  }
}
