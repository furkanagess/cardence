namespace Cardence.Application.DTOs.Auth;

public sealed class ExternalAuthValidationResult
{
    public bool IsSuccess => Profile is not null;
    public ExternalAuthUserInfo? Profile { get; init; }
    public string? ErrorMessage { get; init; }

    public static ExternalAuthValidationResult Ok(ExternalAuthUserInfo profile) =>
        new() { Profile = profile };

    public static ExternalAuthValidationResult Failed(string message) =>
        new() { ErrorMessage = message };
}
