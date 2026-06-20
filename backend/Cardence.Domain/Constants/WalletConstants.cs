namespace Cardence.Domain.Constants;

public static class WalletConstants
{
    public const string FreeTier = "free";
    public const int FreeMaxCards = 15;
    public const string PremiumTier = "premium";

    /// <summary>
    /// Premium cüzdan kayıtları sınırsızdır; veritabanında 0 olarak saklanır.
    /// </summary>
    public const int PremiumMaxCards = 0;

    public static bool HasUnlimitedWalletCards(string tier) =>
        string.Equals(tier, PremiumTier, StringComparison.OrdinalIgnoreCase);
    public const int FreeMaxBusinessCards = 1;
    public const int PremiumMaxBusinessCards = 50;
    public const int FreeMaxManualSavedCards = 1;
    public const int FreeMaxEventGroups = 2;

    public static bool HasUnlimitedEventGroups(string tier) =>
        string.Equals(tier, PremiumTier, StringComparison.OrdinalIgnoreCase);

    /// <summary>
    /// Cardence iş kartları 000000–899999 aralığını kullanır.
    /// </summary>
    public const int BusinessCardIdMaxExclusive = 900_000;

    /// <summary>
    /// Cüzdana manuel eklenen kartlar 900000–999999 aralığını kullanır.
    /// </summary>
    public const int ManualWalletCardIdMin = 900_000;

    public const int ManualWalletCardIdMaxExclusive = 1_000_000;

    public static bool IsManualWalletCardId(string? cardId)
    {
        if (string.IsNullOrWhiteSpace(cardId) ||
            cardId.Trim().Length != BusinessCardConstants.CardIdLength ||
            !int.TryParse(cardId.Trim(), out var numeric))
        {
            return false;
        }

        return numeric >= ManualWalletCardIdMin && numeric < ManualWalletCardIdMaxExclusive;
    }
}
