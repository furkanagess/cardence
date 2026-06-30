namespace Cardence.Application.DTOs.EventGroups;

public sealed class InviteEventGroupCardsByCardIdRequest
{
    public string Id { get; init; } = string.Empty;
    public IReadOnlyList<string> CardIds { get; init; } = [];
}
