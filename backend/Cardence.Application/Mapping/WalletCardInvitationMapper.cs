using Cardence.Application.DTOs.Wallet;
using Cardence.Domain.Entities;

namespace Cardence.Application.Mapping;

public static class WalletCardInvitationMapper
{
    public static WalletCardInvitationDto ToDto(WalletCardInvite invite)
    {
        var card = invite.ProposedCard;
        var inviterName = card?.DisplayName
            ?? card?.CardName
            ?? invite.InviterUser?.DisplayName
            ?? invite.InviterUser?.Email
            ?? "Cardence";

        return new WalletCardInvitationDto
        {
            Id = invite.Id.ToString(),
            InviterUserId = invite.InviterUserId.ToString(),
            InviterName = inviterName,
            InviterPhotoUrl = invite.InviterUser?.PhotoUrl,
            ProposedCardId = invite.ProposedCardId,
            ProposedCardDisplayName = card?.DisplayName ?? card?.CardName,
            ProposedCardTitle = card?.Title,
            ProposedCardCompany = card?.Company,
            ProposedCardPhotoUrl = card?.PhotoUrl,
            SavedCardId = invite.SavedCardId,
            Status = invite.Status,
            CreatedAt = invite.CreatedAtUtc,
            ExpiresAt = invite.ExpiresAtUtc,
        };
    }
}
