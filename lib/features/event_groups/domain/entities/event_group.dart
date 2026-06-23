/// Etkinlik grubu (konferans, networking vb.); kartlar bu gruplara bağlanabilir.
class EventGroup {
  const EventGroup({
    required this.id,
    required this.name,
    this.location,
    this.eventDate,
    this.photoUrl,
  });

  final String id;
  final String name;
  final String? location;
  final DateTime? eventDate;
  final String? photoUrl;
}
