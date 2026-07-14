import '../../domain/entities/wallet_card_invitation.dart';

class WalletCardInvitationModel {
  WalletCardInvitationModel({
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

  static const int _fallbackExpirationDays = 7;

  factory WalletCardInvitationModel.fromJson(Map<String, dynamic> json) {
    final rawCreatedAt = json['createdAt'] ?? json['CreatedAt'];
    final rawExpiresAt = json['expiresAt'] ?? json['ExpiresAt'];
    final createdAt =
        DateTime.tryParse(rawCreatedAt?.toString() ?? '') ?? DateTime.now();
    final expiresAt = rawExpiresAt != null && rawExpiresAt.toString().isNotEmpty
        ? DateTime.tryParse(rawExpiresAt.toString())
        : null;

    return WalletCardInvitationModel(
      id: (json['id'] ?? json['Id'])?.toString() ?? '',
      inviterUserId:
          (json['inviterUserId'] ?? json['InviterUserId'])?.toString() ?? '',
      inviterName:
          (json['inviterName'] ?? json['InviterName'])?.toString() ?? '',
      inviterPhotoUrl:
          (json['inviterPhotoUrl'] ?? json['InviterPhotoUrl'])?.toString(),
      proposedCardId:
          (json['proposedCardId'] ?? json['ProposedCardId'])?.toString() ?? '',
      proposedCardDisplayName: (json['proposedCardDisplayName'] ??
              json['ProposedCardDisplayName'])
          ?.toString(),
      proposedCardTitle:
          (json['proposedCardTitle'] ?? json['ProposedCardTitle'])?.toString(),
      proposedCardCompany: (json['proposedCardCompany'] ??
              json['ProposedCardCompany'])
          ?.toString(),
      proposedCardPhotoUrl: (json['proposedCardPhotoUrl'] ??
              json['ProposedCardPhotoUrl'])
          ?.toString(),
      savedCardId:
          (json['savedCardId'] ?? json['SavedCardId'])?.toString() ?? '',
      status: (json['status'] ?? json['Status'])?.toString() ?? 'pending',
      createdAt: createdAt,
      expiresAt: expiresAt ??
          createdAt.add(const Duration(days: _fallbackExpirationDays)),
    );
  }

  WalletCardInvitation toEntity() => WalletCardInvitation(
        id: id,
        inviterUserId: inviterUserId,
        inviterName: inviterName,
        inviterPhotoUrl: inviterPhotoUrl,
        proposedCardId: proposedCardId,
        proposedCardDisplayName: proposedCardDisplayName,
        proposedCardTitle: proposedCardTitle,
        proposedCardCompany: proposedCardCompany,
        proposedCardPhotoUrl: proposedCardPhotoUrl,
        savedCardId: savedCardId,
        status: status,
        createdAt: createdAt,
        expiresAt: expiresAt,
      );
}
