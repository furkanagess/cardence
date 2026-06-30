namespace Cardence.Application.DTOs.EventGroups;

public sealed class EventGroupDto
{
    public string Id { get; init; } = string.Empty;
    public string Name { get; init; } = string.Empty;
    public string? Location { get; init; }
    public DateTime StartAt { get; init; }
    public DateTime? EndAt { get; init; }
    public string Status { get; init; } = "upcoming";
    public DateTime? EventDate { get; init; }
    public string? PhotoUrl { get; init; }
    public int CardCount { get; init; }
    public DateTime CreatedAt { get; init; }
    public IReadOnlyList<string> InvalidCardIds { get; init; } = [];
}
