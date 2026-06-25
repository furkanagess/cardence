namespace Cardence.Application.DTOs.NetworkGraph;

public sealed class NetworkGraphPathDto
{
    public bool Found { get; init; }
    public int Length { get; init; }
    public IReadOnlyList<GraphNodeDto> Nodes { get; init; } = [];
    public IReadOnlyList<GraphEdgeDto> Edges { get; init; } = [];
    public IReadOnlyList<string> PathNodeIds { get; init; } = [];
}
