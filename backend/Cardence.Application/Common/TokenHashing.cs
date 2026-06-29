using System.Security.Cryptography;
using System.Text;

namespace Cardence.Application.Common;

public static class TokenHashing
{
    public static string HashSha256(string rawToken)
    {
        var bytes = SHA256.HashData(Encoding.UTF8.GetBytes(rawToken));
        return Convert.ToHexString(bytes).ToLowerInvariant();
    }
}
