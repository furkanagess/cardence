namespace Cardence.Domain.Constants;

public static class SavedCardSourceType
{
    public const string Cardence = "cardence";
    public const string Manual = "manual";

    public static bool IsManual(string? sourceType) =>
        string.Equals(sourceType, Manual, StringComparison.OrdinalIgnoreCase);

    public static bool IsCardence(string? sourceType) =>
        string.IsNullOrWhiteSpace(sourceType) ||
        string.Equals(sourceType, Cardence, StringComparison.OrdinalIgnoreCase);

    public static string Normalize(string? sourceType, string cardId)
    {
        if (IsManual(sourceType) || WalletConstants.IsManualWalletCardId(cardId))
        {
            return Manual;
        }

        return Cardence;
    }
}
