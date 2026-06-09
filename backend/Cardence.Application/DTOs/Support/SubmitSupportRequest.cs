namespace Cardence.Application.DTOs.Support;

public sealed class SubmitSupportRequest
{
    public string Email { get; set; } = string.Empty;
    public string Topic { get; set; } = string.Empty;
    public string Message { get; set; } = string.Empty;
}
