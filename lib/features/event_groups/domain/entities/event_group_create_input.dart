/// Yeni etkinlik grubu oluşturma girdisi.
class EventGroupCreateInput {
  const EventGroupCreateInput({
    required this.name,
    required this.location,
    required this.startAt,
    this.endAt,
    this.photoFilePath,
    this.invitedCardIds = const [],
  });

  final String name;
  final String location;
  final DateTime startAt;
  final DateTime? endAt;
  final String? photoFilePath;
  final List<String> invitedCardIds;
}
