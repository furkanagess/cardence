namespace Cardence.Domain.Constants;

public static class WalletConstants
{
    public const string FreeTier = "free";
    public const int FreeMaxCards = 15;

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
