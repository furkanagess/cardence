using Cardence.Application.Common;
using Cardence.Application.Interfaces;
using Cardence.Application.Options;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Options;

namespace Cardence.Api.Controllers;

[ApiController]
[Route("")]
[Tags("Health")]
public sealed class HealthController : ControllerBase
{
    private readonly IHealthStatusReader _healthStatusReader;
    private readonly MonitoringOptions _monitoringOptions;

    public HealthController(
        IHealthStatusReader healthStatusReader,
        IOptions<MonitoringOptions> monitoringOptions)
    {
        _healthStatusReader = healthStatusReader;
        _monitoringOptions = monitoringOptions.Value;
    }

    [HttpGet("Health")]
    [ProducesResponseType(typeof(ApiResponse<HealthResponse>), StatusCodes.Status200OK)]
    public ActionResult<ApiResponse<HealthResponse>> GetHealth()
    {
        var response = ApiResponse<HealthResponse>.Ok(
            new HealthResponse("healthy", "Cardence.Api", DateTime.UtcNow),
            HttpContext.TraceIdentifier);

        return Ok(response);
    }

    /// <summary>
    /// Railway ve harici izleme için API + veritabanı durumu.
    /// Tablo sayıları yalnızca <c>Monitoring__ApiKey</c> ile <c>X-Monitoring-Key</c> header'ı eşleşirse döner.
    /// </summary>
    [HttpGet("health/status")]
    [ProducesResponseType(typeof(SystemHealthStatusResponse), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(SystemHealthStatusResponse), StatusCodes.Status503ServiceUnavailable)]
    public async Task<IActionResult> GetSystemStatus(CancellationToken cancellationToken)
    {
        var includeTableCounts = IsMonitoringKeyValid();
        var snapshot = await _healthStatusReader.ReadAsync(includeTableCounts, cancellationToken);
        var response = SystemHealthStatusResponse.FromSnapshot(snapshot, includeTableCounts);

        return snapshot.Status == "healthy"
            ? Ok(response)
            : StatusCode(StatusCodes.Status503ServiceUnavailable, response);
    }

    private bool IsMonitoringKeyValid()
    {
        var configuredKey = _monitoringOptions.ApiKey;
        if (string.IsNullOrWhiteSpace(configuredKey))
        {
            return false;
        }

        return Request.Headers.TryGetValue("X-Monitoring-Key", out var providedKey)
            && string.Equals(providedKey.ToString(), configuredKey, StringComparison.Ordinal);
    }
}

public sealed record HealthResponse(string Status, string Service, DateTime Timestamp);

public sealed record SystemHealthStatusResponse(
    string Status,
    string Service,
    string Environment,
    string PublicBaseUrl,
    DatabaseStatusResponse Database,
    DateTime Timestamp,
    bool DetailsIncluded)
{
    public static SystemHealthStatusResponse FromSnapshot(
        Application.Health.SystemHealthSnapshot snapshot,
        bool detailsIncluded)
    {
        return new SystemHealthStatusResponse(
            snapshot.Status,
            snapshot.Service,
            snapshot.Environment,
            snapshot.PublicBaseUrl,
            DatabaseStatusResponse.FromSnapshot(snapshot.Database),
            snapshot.Timestamp,
            detailsIncluded);
    }
}

public sealed record DatabaseStatusResponse(
    string Status,
    string Provider,
    long? LatencyMs,
    TableCountsResponse? Counts)
{
    public static DatabaseStatusResponse FromSnapshot(Application.Health.DatabaseHealthSnapshot snapshot)
    {
        return new DatabaseStatusResponse(
            snapshot.Status,
            snapshot.Provider,
            snapshot.LatencyMs,
            snapshot.Counts is null
                ? null
                : new TableCountsResponse(
                    snapshot.Counts.Users,
                    snapshot.Counts.BusinessCards,
                    snapshot.Counts.SavedCards,
                    snapshot.Counts.WalletEntitlements,
                    snapshot.Counts.AuthRefreshTokens));
    }
}

public sealed record TableCountsResponse(
    int Users,
    int BusinessCards,
    int SavedCards,
    int WalletEntitlements,
    int AuthRefreshTokens);
