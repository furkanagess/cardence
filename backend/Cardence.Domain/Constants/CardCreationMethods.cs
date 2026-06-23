namespace Cardence.Domain.Constants;

/// <summary>
/// Kartın nasıl oluşturulduğu / cüzdana nasıl eklendiği.
/// </summary>
public static class CardCreationMethods
{
    public const string OwnCard = "own_card";
    public const string Manual = "manual";
    public const string PhotoScan = "photo_scan";
    public const string CardenceLink = "cardence_link";
    public const string QrScan = "qr_scan";

    public static bool IsManualEntry(string? method) =>
        string.Equals(method, Manual, StringComparison.OrdinalIgnoreCase) ||
        string.Equals(method, PhotoScan, StringComparison.OrdinalIgnoreCase);

    public static bool IsWalletManualTrial(string? method) =>
        IsManualEntry(method);

    public static string NormalizeWallet(
        string? creationMethod,
        string? legacySourceType,
        string cardId,
        bool fromQrPayload)
    {
        if (!string.IsNullOrWhiteSpace(creationMethod))
        {
            var normalized = creationMethod.Trim().ToLowerInvariant();
            return normalized switch
            {
                Manual => Manual,
                PhotoScan => PhotoScan,
                CardenceLink => CardenceLink,
                QrScan => QrScan,
                _ => WalletConstants.IsManualWalletCardId(cardId) ? Manual : CardenceLink,
            };
        }

        if (SavedCardSourceType.IsManual(legacySourceType) ||
            WalletConstants.IsManualWalletCardId(cardId))
        {
            return Manual;
        }

        return fromQrPayload ? QrScan : CardenceLink;
    }

    /// <summary>API geriye dönük uyumluluk: sourceType alanı.</summary>
    public static string ToLegacySourceType(string? creationMethod) =>
        IsManualEntry(creationMethod)
            ? SavedCardSourceType.Manual
            : SavedCardSourceType.Cardence;
}
