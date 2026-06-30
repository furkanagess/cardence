namespace Cardence.Application.DTOs.EventGroups;

public sealed class UpdateEventGroupRequest
{
    public string Id { get; init; } = string.Empty;
    public string Name { get; init; } = string.Empty;
    public string? Location { get; init; }
    public DateTime? StartAt { get; init; }
    public DateTime? EndAt { get; init; }
    public DateTime? EventDate { get; init; }
    public bool ClearPhoto { get; init; }
}
