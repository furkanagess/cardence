namespace Cardence.Application.DTOs.Auth;

public sealed class LinkedInExchangeResult
{
    public LinkedInUserInfo? Profile { get; init; }
    public string? ErrorMessage { get; init; }

    public bool IsSuccess => Profile is not null && string.IsNullOrWhiteSpace(ErrorMessage);

    public static LinkedInExchangeResult Succeeded(LinkedInUserInfo profile) =>
        new() { Profile = profile };

    public static LinkedInExchangeResult Failed(string message) =>
        new() { ErrorMessage = message };
}
