namespace Cardence.Application.Options;

public sealed class LinkedInAuthOptions
{
    public const string SectionName = "LinkedInAuth";

    public string ClientId { get; init; } = string.Empty;
    public string ClientSecret { get; init; } = string.Empty;
    public string RedirectUri { get; init; } = string.Empty;
}
