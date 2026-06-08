using Cardence.Application.DTOs.Auth;

namespace Cardence.Application.Interfaces;

public interface IAuthService
{
    Task<AuthServiceResponse<AuthSessionEntity>> AuthenticationAsync(
        AuthenticationRequest request,
        CancellationToken cancellationToken = default);

    Task<AuthServiceResponse<AuthSessionEntity>> LoginWithPhoneAsync(
        LoginWithPhoneRequest request,
        CancellationToken cancellationToken = default);

    Task<AuthServiceResponse<AuthSessionEntity>> LoginWithEmailAsync(
        LoginWithEmailRequest request,
        CancellationToken cancellationToken = default);

    Task<AuthServiceResponse<object?>> SendOtpAsync(
        SendOtpRequest request,
        CancellationToken cancellationToken = default);

    Task<AuthServiceResponse<AuthSessionEntity>> RefreshAuthenticationAsync(
        RefreshAuthenticationRequest request,
        CancellationToken cancellationToken = default);

    Task<AuthServiceResponse<AuthSessionEntity>> RegisterAsync(
        RegisterRequest request,
        CancellationToken cancellationToken = default);

    Task<AuthServiceResponse<UserProfileEntity>> GetMeAsync(
        Guid userId,
        CancellationToken cancellationToken = default);

    Task<AuthServiceResponse<object?>> ForgotPasswordAsync(
        ForgotPasswordRequest request,
        CancellationToken cancellationToken = default);

    Task<AuthServiceResponse<AuthSessionEntity>> ResetPasswordAsync(
        ResetPasswordRequest request,
        CancellationToken cancellationToken = default);

    Task<AuthServiceResponse<UserProfileEntity>> CompleteOnboardingAsync(
        Guid userId,
        CancellationToken cancellationToken = default);
}
