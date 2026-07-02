using Cardence.Application.DTOs.EventGroups;
using Cardence.Domain.Entities;

namespace Cardence.Application.Mapping;

public static class EventGroupInvitationMapper
{
    public static EventGroupInvitationDto ToDto(EventGroupCardInvite invite)
    {
        var group = invite.EventGroup;
        var inviterName = invite.InviterUser.DisplayName
            ?? invite.InviterUser.Email
            ?? "Cardence";

        return new EventGroupInvitationDto
        {
            Id = invite.Id.ToString(),
            EventGroupId = invite.EventGroupId.ToString(),
            EventName = group.Name,
            Location = group.Location,
            StartAt = group.StartAtUtc,
            EndAt = group.EndAtUtc,
            PhotoUrl = group.PhotoUrl,
            InviterName = inviterName,
            CardId = invite.CardId,
            CardDisplayName = invite.Card.DisplayName ?? invite.Card.CardName,
            Status = invite.Status,
            CreatedAt = invite.CreatedAtUtc,
            ExpiresAt = invite.ExpiresAtUtc,
        };
    }
}
