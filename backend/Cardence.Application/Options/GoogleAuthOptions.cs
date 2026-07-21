namespace Cardence.Application.Options;

public sealed class GoogleAuthOptions
{
    public const string SectionName = "GoogleAuth";

    /// <summary>OAuth Web client ID — idToken audience doğrulaması için.</summary>
    public string ClientId { get; init; } = string.Empty;
}
