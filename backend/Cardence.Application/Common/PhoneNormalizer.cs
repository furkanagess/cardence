using System.Text;

namespace Cardence.Application.Common;

/// <summary>
/// Telefon karşılaştırması ve kayıt için ortak normalizasyon.
/// </summary>
public static class PhoneNormalizer
{
    public static string Normalize(string? phone)
    {
        if (string.IsNullOrWhiteSpace(phone))
        {
            return string.Empty;
        }

        var builder = new StringBuilder();
        foreach (var character in phone.Trim())
        {
            if (char.IsDigit(character))
            {
                builder.Append(character);
                continue;
            }

            if (character == '+' && builder.Length == 0)
            {
                builder.Append(character);
            }
        }

        var normalized = builder.ToString();
        if (normalized.Length == 0)
        {
            return string.Empty;
        }

        if (normalized.StartsWith('+'))
        {
            return normalized;
        }

        if (normalized.StartsWith("00", StringComparison.Ordinal))
        {
            return "+" + normalized[2..];
        }

        // TR: 05xx... veya 5xx... → +90...
        if (normalized.StartsWith('0') && normalized.Length >= 10)
        {
            return "+90" + normalized.TrimStart('0');
        }

        if (normalized.StartsWith("90", StringComparison.Ordinal) && normalized.Length >= 11)
        {
            return "+" + normalized;
        }

        return "+" + normalized;
    }

    public static string DigitsOnly(string? phone)
    {
        if (string.IsNullOrWhiteSpace(phone))
        {
            return string.Empty;
        }

        var builder = new StringBuilder();
        foreach (var character in phone)
        {
            if (char.IsDigit(character))
            {
                builder.Append(character);
            }
        }

        return builder.ToString();
    }

    public static bool AreEquivalent(string? left, string? right)
    {
        var leftNormalized = Normalize(left);
        var rightNormalized = Normalize(right);

        if (leftNormalized.Length > 0 && leftNormalized == rightNormalized)
        {
            return true;
        }

        var leftDigits = DigitsOnly(leftNormalized);
        var rightDigits = DigitsOnly(rightNormalized);

        return leftDigits.Length > 0 && leftDigits == rightDigits;
    }
}
