namespace Cardence.Application.DTOs.Auth;

public sealed class LinkedInUserInfo
{
    public string Sub { get; init; } = string.Empty;
    public string? Email { get; init; }
    public string? DisplayName { get; init; }
    public string? PictureUrl { get; init; }
    public string? ProfileUrl { get; init; }
    public string? Headline { get; init; }
    public string? Title { get; init; }
    public string? Company { get; init; }
    public string? School { get; init; }
    public string? About { get; init; }
}
