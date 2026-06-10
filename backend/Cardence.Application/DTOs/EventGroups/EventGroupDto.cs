namespace Cardence.Application.DTOs.EventGroups;

public sealed class EventGroupDto
{
    public string Id { get; init; } = string.Empty;
    public string Name { get; init; } = string.Empty;
    public int CardCount { get; init; }
    public DateTime CreatedAt { get; init; }
}
