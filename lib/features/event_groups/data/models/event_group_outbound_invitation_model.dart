import '../../domain/entities/event_group_outbound_invitation.dart';

class EventGroupOutboundInvitationModel {
  EventGroupOutboundInvitationModel({
    required this.id,
    required this.eventGroupId,
    required this.cardId,
    this.cardDisplayName,
    this.cardTitle,
    this.cardCompany,
    this.cardPhotoUrl,
    this.inviteeName,
    this.inviteePhotoUrl,
    required this.status,
    required this.createdAt,
    required this.expiresAt,
  });

  final String id;
  final String eventGroupId;
  final String cardId;
  final String? cardDisplayName;
  final String? cardTitle;
  final String? cardCompany;
  final String? cardPhotoUrl;
  final String? inviteeName;
  final String? inviteePhotoUrl;
  final String status;
  final DateTime createdAt;
  final DateTime expiresAt;

  factory EventGroupOutboundInvitationModel.fromJson(Map<String, dynamic> json) {
    final createdAt = DateTime.tryParse(
          (json['createdAt'] ?? json['CreatedAt'])?.toString() ?? '',
        ) ??
        DateTime.now();
    final expiresAt = DateTime.tryParse(
          (json['expiresAt'] ?? json['ExpiresAt'])?.toString() ?? '',
        ) ??
        createdAt.add(const Duration(days: 7));

    return EventGroupOutboundInvitationModel(
      id: (json['id'] ?? json['Id'])?.toString() ?? '',
      eventGroupId:
          (json['eventGroupId'] ?? json['EventGroupId'])?.toString() ?? '',
      cardId: (json['cardId'] ?? json['CardId'])?.toString() ?? '',
      cardDisplayName: (json['cardDisplayName'] ?? json['CardDisplayName'])
          ?.toString(),
      cardTitle: (json['cardTitle'] ?? json['CardTitle'])?.toString(),
      cardCompany: (json['cardCompany'] ?? json['CardCompany'])?.toString(),
      cardPhotoUrl:
          (json['cardPhotoUrl'] ?? json['CardPhotoUrl'])?.toString(),
      inviteeName: (json['inviteeName'] ?? json['InviteeName'])?.toString(),
      inviteePhotoUrl:
          (json['inviteePhotoUrl'] ?? json['InviteePhotoUrl'])?.toString(),
      status: (json['status'] ?? json['Status'])?.toString() ?? 'pending',
      createdAt: createdAt,
      expiresAt: expiresAt,
    );
  }

  EventGroupOutboundInvitation toEntity() => EventGroupOutboundInvitation(
        id: id,
        eventGroupId: eventGroupId,
        cardId: cardId,
        cardDisplayName: cardDisplayName,
        cardTitle: cardTitle,
        cardCompany: cardCompany,
        cardPhotoUrl: cardPhotoUrl,
        inviteeName: inviteeName,
        inviteePhotoUrl: inviteePhotoUrl,
        status: status,
        createdAt: createdAt,
        expiresAt: expiresAt,
      );
}
