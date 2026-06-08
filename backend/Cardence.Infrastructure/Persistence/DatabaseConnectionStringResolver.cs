namespace Cardence.Infrastructure.Persistence;

using Microsoft.Extensions.Configuration;

/// <summary>
/// Resolves PostgreSQL connection strings for local dev, Docker, and Railway.
/// </summary>
public static class DatabaseConnectionStringResolver
{
    public static string? Resolve(IConfiguration configuration)
    {
        var fromConfig = configuration.GetConnectionString("Default");

        var databaseUrl = FirstNonEmpty(
            Environment.GetEnvironmentVariable("DATABASE_URL"),
            Environment.GetEnvironmentVariable("DATABASE_PRIVATE_URL"),
            configuration["DATABASE_URL"],
            configuration["DATABASE_PRIVATE_URL"]);

        if (!string.IsNullOrWhiteSpace(databaseUrl))
        {
            return NormalizeDatabaseUrl(databaseUrl);
        }

        var pgHost = Environment.GetEnvironmentVariable("PGHOST");
        if (!string.IsNullOrWhiteSpace(pgHost))
        {
            return BuildFromPostgresEnv();
        }

        return fromConfig;
    }

    public static bool LooksLikeLocalDefault(string? connectionString)
    {
        if (string.IsNullOrWhiteSpace(connectionString))
        {
            return true;
        }

        var normalized = connectionString.ToLowerInvariant();
        return normalized.Contains("localhost")
            || normalized.Contains("127.0.0.1")
            || normalized.Contains("host.docker.internal");
    }

    private static string BuildFromPostgresEnv()
    {
        var host = Environment.GetEnvironmentVariable("PGHOST")!;
        var port = Environment.GetEnvironmentVariable("PGPORT") ?? "5432";
        var user = Environment.GetEnvironmentVariable("PGUSER") ?? "postgres";
        var password = Environment.GetEnvironmentVariable("PGPASSWORD") ?? string.Empty;
        var database = Environment.GetEnvironmentVariable("PGDATABASE") ?? "railway";

        return $"Host={host};Port={port};Database={database};Username={user};Password={password};SSL Mode=Require;Trust Server Certificate=true";
    }

    private static string NormalizeDatabaseUrl(string databaseUrl)
    {
        if (databaseUrl.StartsWith("postgres://", StringComparison.OrdinalIgnoreCase))
        {
            return "postgresql://" + databaseUrl["postgres://".Length..];
        }

        return databaseUrl;
    }

    private static string? FirstNonEmpty(params string?[] values)
    {
        foreach (var value in values)
        {
            if (!string.IsNullOrWhiteSpace(value))
            {
                return value;
            }
        }

        return null;
    }
}
