namespace Cardence.Application.Options;

public sealed class RevenueCatOptions
{
    public const string SectionName = "RevenueCat";

    public string WebhookAuthorizationToken { get; init; } = string.Empty;
    public string PremiumEntitlementId { get; init; } = "premium";
}
