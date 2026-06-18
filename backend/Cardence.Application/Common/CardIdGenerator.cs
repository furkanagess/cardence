using System.Text.RegularExpressions;
using Cardence.Application.Validation;
using Cardence.Domain.Constants;

namespace Cardence.Application.Common;

public static class CardIdGenerator
{
    public static bool IsValid(string? cardId)
    {
        if (string.IsNullOrWhiteSpace(cardId))
        {
            return false;
        }

        return Regex.IsMatch(
            cardId.Trim(),
            ValidationPatterns.CardId,
            RegexOptions.CultureInvariant);
    }

    public static string GenerateCandidate()
    {
        return Random.Shared.Next(0, WalletConstants.BusinessCardIdMaxExclusive)
            .ToString($"D{BusinessCardConstants.CardIdLength}");
    }

    public static string GenerateManualWalletCandidate()
    {
        return Random.Shared.Next(
                WalletConstants.ManualWalletCardIdMin,
                WalletConstants.ManualWalletCardIdMaxExclusive)
            .ToString($"D{BusinessCardConstants.CardIdLength}");
    }

    public static bool IsManualWalletId(string? cardId) =>
        WalletConstants.IsManualWalletCardId(cardId);

    public static async Task<string> GenerateUniqueAsync(
        Func<string, CancellationToken, Task<bool>> existsAsync,
        CancellationToken cancellationToken = default)
    {
        for (var attempt = 0; attempt < 100; attempt++)
        {
            var candidate = GenerateCandidate();
            if (!await existsAsync(candidate, cancellationToken))
            {
                return candidate;
            }
        }

        throw new InvalidOperationException("Unable to generate a unique card id.");
    }
}
