namespace Cardence.Application.DTOs.NetworkGraph;

public sealed class NetworkGraphDto
{
    public required string Scope { get; init; }
    public IReadOnlyList<GraphNodeDto> Nodes { get; init; } = [];
    public IReadOnlyList<GraphEdgeDto> Edges { get; init; } = [];
    public NetworkGraphMetricsDto Metrics { get; init; } = new();
}
