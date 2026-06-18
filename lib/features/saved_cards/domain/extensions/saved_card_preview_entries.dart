import '../entities/saved_card.dart';

/// Kayıtlı kart önizlemesi için arka yüz girişleri.
extension SavedCardPreviewEntries on SavedCard {
  List<({String label, String value})> get backAboutEntries {
    final items = <({String label, String value})>[];
    final about = this.about?.trim();
    items.add((
      label: 'Hakkımda',
      value: (about != null && about.isNotEmpty) ? about : '',
    ));

    final skills = this.skills?.trim();
    if (skills != null && skills.isNotEmpty) {
      items.add((label: 'Yetenekler', value: skills));
    }

    return items;
  }
}
