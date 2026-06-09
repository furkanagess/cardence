namespace Cardence.Infrastructure.Persistence;

using Microsoft.Extensions.Configuration;

/// <summary>
/// Resolves PostgreSQL connection strings for local dev, Docker, and Railway.
/// </summary>
public static class DatabaseConnectionStringResolver
{
    public static string? Resolve(IConfiguration configuration)
    {
        var fromConfig = NullIfWhiteSpace(configuration.GetConnectionString("Default"));

        var databaseUrl = FirstNonEmpty(
            Environment.GetEnvironmentVariable("DATABASE_URL"),
            Environment.GetEnvironmentVariable("DATABASE_PRIVATE_URL"),
            configuration["DATABASE_URL"],
            configuration["DATABASE_PRIVATE_URL"]);

        if (!string.IsNullOrWhiteSpace(databaseUrl))
        {
            return ToNpgsqlConnectionString(databaseUrl);
        }

        var pgHost = Environment.GetEnvironmentVariable("PGHOST");
        if (!string.IsNullOrWhiteSpace(pgHost))
        {
            return BuildFromPostgresEnv();
        }

        return ToNpgsqlConnectionString(fromConfig);
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

        return BuildNpgsql(host, port, database, user, password);
    }

    private static string? ToNpgsqlConnectionString(string? connectionString)
    {
        if (string.IsNullOrWhiteSpace(connectionString))
        {
            return null;
        }

        var trimmed = connectionString.Trim();
        if (IsPostgresUri(trimmed))
        {
            return ConvertPostgresUriToNpgsql(trimmed);
        }

        return trimmed;
    }

    private static bool IsPostgresUri(string value) =>
        value.StartsWith("postgres://", StringComparison.OrdinalIgnoreCase)
        || value.StartsWith("postgresql://", StringComparison.OrdinalIgnoreCase);

    private static string ConvertPostgresUriToNpgsql(string databaseUrl)
    {
        var normalized = databaseUrl.StartsWith("postgres://", StringComparison.OrdinalIgnoreCase)
            ? "postgresql://" + databaseUrl["postgres://".Length..]
            : databaseUrl;

        var uri = new Uri(normalized);
        var userInfo = uri.UserInfo.Split(':', 2);
        var username = Uri.UnescapeDataString(userInfo[0]);
        var password = userInfo.Length > 1 ? Uri.UnescapeDataString(userInfo[1]) : string.Empty;
        var database = uri.AbsolutePath.TrimStart('/');
        if (string.IsNullOrWhiteSpace(database))
        {
            database = "railway";
        }

        var port = uri.Port > 0 ? uri.Port.ToString() : "5432";
        return BuildNpgsql(uri.Host, port, database, username, password);
    }

    private static string BuildNpgsql(
        string host,
        string port,
        string database,
        string username,
        string password)
    {
        return $"Host={host};Port={port};Database={database};Username={username};Password={password};SSL Mode=Require;Trust Server Certificate=true";
    }

    private static string? NullIfWhiteSpace(string? value) =>
        string.IsNullOrWhiteSpace(value) ? null : value.Trim();

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
