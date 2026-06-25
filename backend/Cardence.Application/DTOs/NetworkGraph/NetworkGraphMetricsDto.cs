namespace Cardence.Application.DTOs.NetworkGraph;

public sealed class NetworkGraphMetricsDto
{
    public int NodeCount { get; init; }
    public int EdgeCount { get; init; }
    public string? CenterCardId { get; init; }
}
