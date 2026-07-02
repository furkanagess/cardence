/// Yeni etkinlik grubu oluşturma girdisi.
class EventGroupCreateInput {
  const EventGroupCreateInput({
    required this.name,
    required this.location,
    required this.startAt,
    this.endAt,
    this.description,
    this.photoFilePath,
    this.invitedCardIds = const [],
  });

  final String name;
  final String location;
  final DateTime startAt;
  final DateTime? endAt;
  final String? description;
  final String? photoFilePath;
  final List<String> invitedCardIds;
}
