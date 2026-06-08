namespace Cardence.Application.Options;

public sealed class JwtOptions
{
    public const string SectionName = "Jwt";

    public string Issuer { get; init; } = "Cardence";
    public string Audience { get; init; } = "Cardence.App";
    public string SigningKey { get; init; } = string.Empty;
    public int AccessTokenMinutes { get; init; } = 60;
    public int RefreshTokenDays { get; init; } = 30;
}
