namespace Cardence.Application.DTOs.Auth;

/// <summary>
/// Authentication servisleri için standart yanıt zarfı.
/// </summary>
public sealed class AuthServiceResponse<T>
{
    public AuthErrorDetail Error { get; init; } = AuthErrorDetail.None;
    public bool Success { get; init; }
    public string Message { get; init; } = string.Empty;
    public T? Entity { get; init; }

    public static AuthServiceResponse<T> Ok(T entity, string message = "Success") => new()
    {
        Success = true,
        Message = message,
        Entity = entity,
        Error = AuthErrorDetail.None,
    };

    public static AuthServiceResponse<T> Fail(
        int code,
        string description,
        string message) => new()
    {
        Success = false,
        Message = message,
        Entity = default,
        Error = AuthErrorDetail.Create(code, description, message),
    };
}
