namespace Cardence.Application.DTOs.Wallet;

public sealed class WalletQuotaDto
{
    public string Tier { get; init; } = "free";
    public int UsedCount { get; init; }
    public int MaxCards { get; init; }
    public int Remaining { get; init; }
    public bool CanAddMore { get; init; }
    public bool IsNearLimit { get; init; }
    public double UsageFraction { get; init; }
    public int BusinessCardCount { get; init; }
    public int MaxBusinessCards { get; init; }
    public bool CanAddBusinessCard { get; init; }
    public bool CanAddManualSavedCard { get; init; }
    public int EventGroupCount { get; init; }
    public int MaxEventGroups { get; init; }
    public bool CanAddEventGroup { get; init; }
}
