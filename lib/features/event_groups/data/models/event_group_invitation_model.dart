import '../../domain/entities/event_group_invitation.dart';

class EventGroupInvitationModel {
  EventGroupInvitationModel({
    required this.id,
    required this.eventGroupId,
    required this.eventName,
    this.location,
    required this.startAt,
    this.endAt,
    this.photoUrl,
    required this.inviterName,
    required this.cardId,
    this.cardDisplayName,
    required this.status,
    required this.createdAt,
  });

  final String id;
  final String eventGroupId;
  final String eventName;
  final String? location;
  final DateTime startAt;
  final DateTime? endAt;
  final String? photoUrl;
  final String inviterName;
  final String cardId;
  final String? cardDisplayName;
  final String status;
  final DateTime createdAt;

  factory EventGroupInvitationModel.fromJson(Map<String, dynamic> json) {
    final rawStartAt = json['startAt'] ?? json['StartAt'];
    final rawEndAt = json['endAt'] ?? json['EndAt'];
    final rawCreatedAt = json['createdAt'] ?? json['CreatedAt'];

    return EventGroupInvitationModel(
      id: (json['id'] ?? json['Id'])?.toString() ?? '',
      eventGroupId:
          (json['eventGroupId'] ?? json['EventGroupId'])?.toString() ?? '',
      eventName: (json['eventName'] ?? json['EventName'])?.toString() ?? '',
      location: (json['location'] ?? json['Location'])?.toString(),
      startAt: DateTime.tryParse(rawStartAt?.toString() ?? '') ??
          DateTime.now(),
      endAt: rawEndAt != null && rawEndAt.toString().isNotEmpty
          ? DateTime.tryParse(rawEndAt.toString())
          : null,
      photoUrl: (json['photoUrl'] ?? json['PhotoUrl'])?.toString(),
      inviterName:
          (json['inviterName'] ?? json['InviterName'])?.toString() ?? '',
      cardId: (json['cardId'] ?? json['CardId'])?.toString() ?? '',
      cardDisplayName:
          (json['cardDisplayName'] ?? json['CardDisplayName'])?.toString(),
      status: (json['status'] ?? json['Status'])?.toString() ?? 'pending',
      createdAt: DateTime.tryParse(rawCreatedAt?.toString() ?? '') ??
          DateTime.now(),
    );
  }

  EventGroupInvitation toEntity() => EventGroupInvitation(
        id: id,
        eventGroupId: eventGroupId,
        eventName: eventName,
        location: location,
        startAt: startAt,
        endAt: endAt,
        photoUrl: photoUrl,
        inviterName: inviterName,
        cardId: cardId,
        cardDisplayName: cardDisplayName,
        status: status,
        createdAt: createdAt,
      );
}
