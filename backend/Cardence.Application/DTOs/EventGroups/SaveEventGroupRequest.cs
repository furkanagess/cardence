namespace Cardence.Application.DTOs.EventGroups;

public sealed class SaveEventGroupRequest
{
    public string Name { get; init; } = string.Empty;
    public string? Location { get; init; }
    public DateTime? EventDate { get; init; }
}
