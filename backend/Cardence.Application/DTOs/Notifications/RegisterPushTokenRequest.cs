namespace Cardence.Application.DTOs.Notifications;

public sealed class RegisterPushTokenRequest
{
    public string Token { get; init; } = string.Empty;
    public string Platform { get; init; } = string.Empty;
}
