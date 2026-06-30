class EventGroupUpdateInput {
  const EventGroupUpdateInput({
    required this.id,
    required this.name,
    required this.location,
    required this.startAt,
    this.endAt,
    this.photoFilePath,
    this.clearPhoto = false,
  });

  final String id;
  final String name;
  final String location;
  final DateTime startAt;
  final DateTime? endAt;
  final String? photoFilePath;
  final bool clearPhoto;
}
