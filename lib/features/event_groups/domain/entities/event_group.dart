/// Etkinlik grubu (konferans, networking vb.); kartlar bu gruplara bağlanabilir.
enum EventGroupStatus {
  upcoming,
  ongoing,
  ended,
}

class EventGroup {
  const EventGroup({
    required this.id,
    required this.name,
    this.location,
    this.description,
    required this.startAt,
    this.endAt,
    this.status = EventGroupStatus.upcoming,
    this.photoUrl,
    this.invalidCardIds = const [],
  });

  final String id;
  final String name;
  final String? location;
  final String? description;
  final DateTime startAt;
  final DateTime? endAt;
  final EventGroupStatus status;
  final String? photoUrl;
  final List<String> invalidCardIds;

  /// Eski UI parçaları geçiş sürecinde bu alanı kullanıyor.
  DateTime? get eventDate => startAt;
}
