class EventGroupInvitation {
  const EventGroupInvitation({
    required this.id,
    required this.eventGroupId,
    required this.eventName,
    this.description,
    this.location,
    required this.startAt,
    this.endAt,
    this.photoUrl,
    required this.inviterName,
    required this.cardId,
    this.cardDisplayName,
    required this.status,
    required this.createdAt,
    required this.expiresAt,
  });

  final String id;
  final String eventGroupId;
  final String eventName;
  final String? description;
  final String? location;
  final DateTime startAt;
  final DateTime? endAt;
  final String? photoUrl;
  final String inviterName;
  final String cardId;
  final String? cardDisplayName;
  final String status;
  final DateTime createdAt;
  final DateTime expiresAt;
}
