namespace Cardence.Application.DTOs.Auth;

public sealed class SendOtpRequest
{
    public string Phone { get; init; } = string.Empty;
    public string? UdId { get; init; }
}
