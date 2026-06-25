namespace Cardence.Domain.Constants;

public static class WalletConstants
{
    public const string FreeTier = "free";
    public const int FreeMaxCards = 15;
    public const string PremiumTier = "premium";
    public const string BusinessTier = "business";
    public const string EnterpriseTier = "enterprise";

    /// <summary>
    /// Premium cüzdan kayıtları sınırsızdır; veritabanında 0 olarak saklanır.
    /// </summary>
    public const int PremiumMaxCards = 0;

    /// <summary>
    /// Premium ve üzeri planlarda cüzdan kayıtları sınırsızdır.
    /// </summary>
    public static bool HasUnlimitedWalletCards(string tier) =>
        IsPremiumOrHigher(tier);

    public const int FreeMaxBusinessCards = 2;
    public const int PremiumMaxBusinessCards = 50;

    /// <summary>
    /// Manuel / fotoğrafla cüzdan kartı ekleme tüm kullanıcılara açık.
    /// </summary>
    public const int FreeMaxManualSavedCards = int.MaxValue;
    public const int FreeMaxEventGroups = 2;

    public static string NormalizeTier(string? tier)
    {
        var normalized = tier?.Trim().ToLowerInvariant();
        return normalized switch
        {
            PremiumTier => PremiumTier,
            BusinessTier => BusinessTier,
            EnterpriseTier => EnterpriseTier,
            _ => FreeTier,
        };
    }

    public static bool IsPremiumOrHigher(string tier)
    {
        var normalized = NormalizeTier(tier);
        return normalized is PremiumTier or BusinessTier or EnterpriseTier;
    }

    public static bool IsBusinessOrHigher(string tier)
    {
        var normalized = NormalizeTier(tier);
        return normalized is BusinessTier or EnterpriseTier;
    }

    public static int? GetMaxBusinessCards(string tier)
    {
        var normalized = NormalizeTier(tier);
        return normalized switch
        {
            PremiumTier => PremiumMaxBusinessCards,
            BusinessTier or EnterpriseTier => null,
            _ => FreeMaxBusinessCards,
        };
    }

    public static bool HasUnlimitedEventGroups(string tier) =>
        IsPremiumOrHigher(tier);

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
