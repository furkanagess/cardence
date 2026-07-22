namespace Cardence.Application.Options;

public sealed class RevenueCatOptions
{
    public const string SectionName = "RevenueCat";

    public string WebhookAuthorizationToken { get; init; } = string.Empty;

    /// <summary>RevenueCat secret API key (server-side subscriber lookup).</summary>
    public string SecretApiKey { get; init; } = string.Empty;

    public string PremiumEntitlementId { get; init; } = "cardence-pro";

    /// <summary>
    /// Virgülle ayrılmış ek premium entitlement kimlikleri
    /// (örn. cardence-pro-discount).
    /// </summary>
    public string PremiumEntitlementIds { get; init; } =
        "cardence-pro,cardence-pro-discount";
}
