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
}
