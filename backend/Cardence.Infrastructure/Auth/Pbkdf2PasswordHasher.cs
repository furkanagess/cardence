using System.Security.Cryptography;
using Cardence.Application.Interfaces;

namespace Cardence.Infrastructure.Auth;

public sealed class Pbkdf2PasswordHasher : IPasswordHasher
{
    private const int SaltSize = 16;
    private const int KeySize = 32;
    private const int Iterations = 100_000;
    private static readonly HashAlgorithmName Algorithm = HashAlgorithmName.SHA256;

    public string Hash(string password)
    {
        var salt = RandomNumberGenerator.GetBytes(SaltSize);
        var hash = Rfc2898DeriveBytes.Pbkdf2(
            password,
            salt,
            Iterations,
            Algorithm,
            KeySize);

        return string.Join(
            '.',
            Convert.ToBase64String(salt),
            Convert.ToBase64String(hash));
    }

    public bool Verify(string password, string? passwordHash)
    {
        if (string.IsNullOrWhiteSpace(passwordHash))
        {
            return false;
        }

        var parts = passwordHash.Split('.', 2);
        if (parts.Length != 2)
        {
            return false;
        }

        byte[] salt;
        byte[] expectedHash;
        try
        {
            salt = Convert.FromBase64String(parts[0]);
            expectedHash = Convert.FromBase64String(parts[1]);
        }
        catch (FormatException)
        {
            return false;
        }

        var actualHash = Rfc2898DeriveBytes.Pbkdf2(
            password,
            salt,
            Iterations,
            Algorithm,
            expectedHash.Length);

        return CryptographicOperations.FixedTimeEquals(actualHash, expectedHash);
    }
}
