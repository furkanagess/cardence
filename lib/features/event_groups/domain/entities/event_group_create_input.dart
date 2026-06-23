/// Yeni etkinlik grubu oluşturma girdisi.
class EventGroupCreateInput {
  const EventGroupCreateInput({
    required this.name,
    this.location,
    this.eventDate,
    this.photoFilePath,
  });

  final String name;
  final String? location;
  final DateTime? eventDate;
  final String? photoFilePath;
}
