namespace Cardence.Application.DTOs.EventGroups;

public sealed class LinkEventGroupCardsRequest
{
    public string Id { get; init; } = string.Empty;
    public IReadOnlyList<string> CardIds { get; init; } = [];
}
