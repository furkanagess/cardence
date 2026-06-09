namespace Cardence.Application.Health;

public sealed record SystemHealthSnapshot(
    string Status,
    string Service,
    string Environment,
    string PublicBaseUrl,
    DatabaseHealthSnapshot Database,
    DateTime Timestamp);

public sealed record DatabaseHealthSnapshot(
    string Status,
    string Provider,
    long? LatencyMs,
    TableCountsSnapshot? Counts);

public sealed record TableCountsSnapshot(
    int Users,
    int BusinessCards,
    int SavedCards,
    int WalletEntitlements,
    int AuthRefreshTokens);
