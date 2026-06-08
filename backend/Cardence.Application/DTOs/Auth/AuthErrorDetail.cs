using System.Text.Json.Serialization;

namespace Cardence.Application.DTOs.Auth;

public sealed class AuthErrorDetail
{
    [JsonPropertyName("Code")]
    public int Code { get; init; }

    [JsonPropertyName("Description")]
    public string Description { get; init; } = string.Empty;

    [JsonPropertyName("Message")]
    public string Message { get; init; } = string.Empty;

    public static AuthErrorDetail None { get; } = new()
    {
        Code = 0,
        Description = string.Empty,
        Message = string.Empty,
    };

    public static AuthErrorDetail Create(int code, string description, string message) => new()
    {
        Code = code,
        Description = description,
        Message = message,
    };
}
