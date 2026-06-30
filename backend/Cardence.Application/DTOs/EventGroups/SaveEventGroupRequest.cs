namespace Cardence.Application.DTOs.EventGroups;

public sealed class SaveEventGroupRequest
{
    public string Name { get; init; } = string.Empty;
    public string? Location { get; init; }
    public DateTime? StartAt { get; init; }
    public DateTime? EndAt { get; init; }
    public DateTime? EventDate { get; init; }
    public IReadOnlyList<string> InvitedCardIds { get; init; } = [];
}
