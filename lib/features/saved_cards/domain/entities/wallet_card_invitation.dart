class WalletCardInvitation {
  const WalletCardInvitation({
    required this.id,
    required this.inviterUserId,
    required this.inviterName,
    this.inviterPhotoUrl,
    required this.proposedCardId,
    this.proposedCardDisplayName,
    this.proposedCardTitle,
    this.proposedCardCompany,
    this.proposedCardPhotoUrl,
    required this.savedCardId,
    required this.status,
    required this.createdAt,
    required this.expiresAt,
  });

  final String id;
  final String inviterUserId;
  final String inviterName;
  final String? inviterPhotoUrl;
  final String proposedCardId;
  final String? proposedCardDisplayName;
  final String? proposedCardTitle;
  final String? proposedCardCompany;
  final String? proposedCardPhotoUrl;
  final String savedCardId;
  final String status;
  final DateTime createdAt;
  final DateTime expiresAt;

  String get displayCardName {
    final name = proposedCardDisplayName?.trim();
    if (name != null && name.isNotEmpty) return name;
    return proposedCardId;
  }
}
