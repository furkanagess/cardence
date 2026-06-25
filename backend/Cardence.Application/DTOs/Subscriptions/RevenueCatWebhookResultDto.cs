namespace Cardence.Application.DTOs.Subscriptions;

public sealed class RevenueCatWebhookResultDto
{
    public bool Processed { get; init; }
    public bool Duplicate { get; init; }
    public string Tier { get; init; } = "free";
    public string EventType { get; init; } = string.Empty;
}
