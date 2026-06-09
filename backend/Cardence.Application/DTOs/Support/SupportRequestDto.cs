namespace Cardence.Application.DTOs.Support;

public sealed class SupportRequestDto
{
    public Guid RequestId { get; set; }
    public string Email { get; set; } = string.Empty;
    public string Topic { get; set; } = string.Empty;
    public DateTime CreatedAt { get; set; }
}
