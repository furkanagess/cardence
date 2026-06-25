namespace Cardence.Application.DTOs.NetworkGraph;

public sealed class GraphEdgeDto
{
    public required string Id { get; init; }
    public required string Source { get; init; }
    public required string Target { get; init; }
    public required string Type { get; init; }
    public int Weight { get; init; }
    public DateTime? OccurredAt { get; init; }
    public Guid? EventGroupId { get; init; }
    public Guid? OrganizationEventId { get; init; }
}
