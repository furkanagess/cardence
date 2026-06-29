namespace Cardence.Application.Options;

public sealed class PasswordResetOptions
{
    public const string SectionName = "PasswordReset";

    /// <summary>
    /// Mobil deep link veya web reset sayfası tabanı.
    /// Örnek: https://cardenceapi.app/auth/reset-password
    /// </summary>
    public string ResetBaseUrl { get; init; } = "https://cardenceapi.app/auth/reset-password";

    public int TokenLifetimeMinutes { get; init; } = 30;
}
