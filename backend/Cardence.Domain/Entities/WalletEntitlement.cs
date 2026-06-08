namespace Cardence.Domain.Entities;

public sealed class WalletEntitlement
{
    public Guid UserId { get; set; }
    public string Tier { get; set; } = "free";
    public int MaxCards { get; set; } = 15;
    public DateTime UpdatedAt { get; set; }

    public User User { get; set; } = null!;
}
