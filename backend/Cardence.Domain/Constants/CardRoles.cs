namespace Cardence.Domain.Constants;

public static class CardRoles
{
    public const string Own = "own";
    public const string Wallet = "wallet";

    public static bool IsOwn(string? role) =>
        string.Equals(role, Own, StringComparison.OrdinalIgnoreCase);

    public static bool IsWallet(string? role) =>
        string.Equals(role, Wallet, StringComparison.OrdinalIgnoreCase);
}
