class EventGroupOutboundInvitation {
  const EventGroupOutboundInvitation({
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

  String get displayName {
    final invitee = inviteeName?.trim();
    if (invitee != null && invitee.isNotEmpty) return invitee;
    final card = cardDisplayName?.trim();
    if (card != null && card.isNotEmpty) return card;
    return cardId;
  }

  bool get isPending => status.toLowerCase() == 'pending';
  bool get isAccepted => status.toLowerCase() == 'accepted';
  bool get isRejected => status.toLowerCase() == 'rejected';
}
