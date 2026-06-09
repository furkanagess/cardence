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
        return Random.Shared.Next(0, 1_000_000).ToString($"D{BusinessCardConstants.CardIdLength}");
    }

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
