using System.Diagnostics;
using Cardence.Application.Health;
using Cardence.Application.Interfaces;
using Cardence.Application.Options;
using Cardence.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Options;

namespace Cardence.Infrastructure.Health;

public sealed class HealthStatusReader : IHealthStatusReader
{
    private readonly CardenceDbContext _dbContext;
    private readonly IHostEnvironment _environment;
    private readonly ApiOptions _apiOptions;

    public HealthStatusReader(
        CardenceDbContext dbContext,
        IHostEnvironment environment,
        IOptions<ApiOptions> apiOptions)
    {
        _dbContext = dbContext;
        _environment = environment;
        _apiOptions = apiOptions.Value;
    }

    public async Task<SystemHealthSnapshot> ReadAsync(
        bool includeTableCounts,
        CancellationToken cancellationToken = default)
    {
        var stopwatch = Stopwatch.StartNew();
        var provider = _dbContext.Database.IsRelational() ? "PostgreSQL" : "InMemory";

        try
        {
            var canConnect = await _dbContext.Database.CanConnectAsync(cancellationToken);
            stopwatch.Stop();

            if (!canConnect)
            {
                return BuildSnapshot(
                    status: "unhealthy",
                    provider: provider,
                    latencyMs: stopwatch.ElapsedMilliseconds,
                    counts: null);
            }

            TableCountsSnapshot? counts = null;
            if (includeTableCounts)
            {
                counts = await ReadTableCountsAsync(cancellationToken);
            }

            return BuildSnapshot(
                status: "healthy",
                provider: provider,
                latencyMs: stopwatch.ElapsedMilliseconds,
                counts: counts);
        }
        catch
        {
            stopwatch.Stop();
            return BuildSnapshot(
                status: "unhealthy",
                provider: provider,
                latencyMs: stopwatch.ElapsedMilliseconds,
                counts: null);
        }
    }

    private async Task<TableCountsSnapshot> ReadTableCountsAsync(CancellationToken cancellationToken)
    {
        var users = await _dbContext.Users.CountAsync(cancellationToken);
        var businessCards = await _dbContext.BusinessCards.CountAsync(cancellationToken);
        var savedCards = await _dbContext.SavedCards.CountAsync(cancellationToken);
        var walletEntitlements = await _dbContext.WalletEntitlements.CountAsync(cancellationToken);
        var authRefreshTokens = await _dbContext.AuthRefreshTokens.CountAsync(cancellationToken);

        return new TableCountsSnapshot(
            users,
            businessCards,
            savedCards,
            walletEntitlements,
            authRefreshTokens);
    }

    private SystemHealthSnapshot BuildSnapshot(
        string status,
        string provider,
        long latencyMs,
        TableCountsSnapshot? counts)
    {
        return new SystemHealthSnapshot(
            Status: status,
            Service: "Cardence.Api",
            Environment: _environment.EnvironmentName,
            PublicBaseUrl: _apiOptions.PublicBaseUrl.TrimEnd('/'),
            Database: new DatabaseHealthSnapshot(
                Status: status,
                Provider: provider,
                LatencyMs: latencyMs,
                Counts: counts),
            Timestamp: DateTime.UtcNow);
    }
}
