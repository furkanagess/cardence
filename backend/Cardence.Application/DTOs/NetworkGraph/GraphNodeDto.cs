namespace Cardence.Application.DTOs.NetworkGraph;

public sealed class GraphNodeDto
{
    public required string Id { get; init; }
    public required string Type { get; init; }
    public required string Label { get; init; }
    public string? Subtitle { get; init; }
    public string? CardId { get; init; }
    public string? Company { get; init; }
    public string? PhotoUrl { get; init; }
    public int Degree { get; init; }
    public bool IsCenter { get; init; }
    public bool IsOwnCard { get; init; }
}
