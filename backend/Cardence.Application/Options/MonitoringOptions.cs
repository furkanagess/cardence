namespace Cardence.Application.Options;

public sealed class MonitoringOptions
{
    public const string SectionName = "Monitoring";

    /// <summary>
    /// Optional API key for <c>GET /health/status</c> table counts.
    /// Set on Railway as <c>Monitoring__ApiKey</c>.
    /// </summary>
    public string ApiKey { get; init; } = string.Empty;
}
