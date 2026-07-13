namespace Cardence.Application.DTOs.EventGroups;

public sealed class EventGroupInviteCardsResult
{
    public IReadOnlyList<string> InvalidCardIds { get; init; } = [];
    public IReadOnlyList<CreatedEventGroupInvite> NewInvites { get; init; } = [];
}

public sealed class CreatedEventGroupInvite
{
    public Guid InvitationId { get; init; }
    public Guid InviteeUserId { get; init; }
    public Guid InviterUserId { get; init; }
    public Guid EventGroupId { get; init; }
    public string CardId { get; init; } = string.Empty;
}
