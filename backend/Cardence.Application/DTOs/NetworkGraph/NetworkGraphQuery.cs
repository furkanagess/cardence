using Cardence.Domain.Graph;

namespace Cardence.Application.DTOs.NetworkGraph;

public sealed class NetworkGraphQuery
{
    public GraphScope Scope { get; init; } = GraphScope.Personal;
    public Guid? EventGroupId { get; init; }
    public Guid? OrganizationId { get; init; }
    public Guid? OrganizationEventId { get; init; }
    public string? CenterCardId { get; init; }
    public int MaxDepth { get; init; } = 2;
    public int MaxNodes { get; init; } = 100;
}
