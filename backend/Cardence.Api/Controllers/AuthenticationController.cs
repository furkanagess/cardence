using Cardence.Application.DTOs.Auth;
using Cardence.Application.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace Cardence.Api.Controllers;

[ApiController]
[Route("")]
[Tags("Authentication")]
public sealed class AuthenticationController : ControllerBase
{
    private readonly IAuthService _authService;
    private readonly ICurrentUserService _currentUserService;

    public AuthenticationController(
        IAuthService authService,
        ICurrentUserService currentUserService)
    {
        _authService = authService;
        _currentUserService = currentUserService;
    }

    [HttpPost("Authentication")]
    [ProducesResponseType(typeof(AuthServiceResponse<AuthSessionEntity>), StatusCodes.Status200OK)]
    public async Task<ActionResult<AuthServiceResponse<AuthSessionEntity>>> Authentication(
        [FromBody] AuthenticationRequest request,
        CancellationToken cancellationToken)
    {
        var response = await _authService.AuthenticationAsync(request, cancellationToken);
        return Ok(response);
    }

    [HttpPost("LoginWithPhone")]
    [ProducesResponseType(typeof(AuthServiceResponse<AuthSessionEntity>), StatusCodes.Status200OK)]
    public async Task<ActionResult<AuthServiceResponse<AuthSessionEntity>>> LoginWithPhone(
        [FromBody] LoginWithPhoneRequest request,
        CancellationToken cancellationToken)
    {
        var response = await _authService.LoginWithPhoneAsync(request, cancellationToken);
        return Ok(response);
    }

    [HttpPost("LoginWithEmail")]
    [ProducesResponseType(typeof(AuthServiceResponse<AuthSessionEntity>), StatusCodes.Status200OK)]
    public async Task<ActionResult<AuthServiceResponse<AuthSessionEntity>>> LoginWithEmail(
        [FromBody] LoginWithEmailRequest request,
        CancellationToken cancellationToken)
    {
        var response = await _authService.LoginWithEmailAsync(request, cancellationToken);
        return Ok(response);
    }

    [HttpPost("LoginWithLinkedIn")]
    [ProducesResponseType(typeof(AuthServiceResponse<AuthSessionEntity>), StatusCodes.Status200OK)]
    public async Task<ActionResult<AuthServiceResponse<AuthSessionEntity>>> LoginWithLinkedIn(
        [FromBody] LoginWithLinkedInRequest request,
        CancellationToken cancellationToken)
    {
        var response = await _authService.LoginWithLinkedInAsync(request, cancellationToken);
        return Ok(response);
    }

    [HttpPost("SendOTP")]
    [ProducesResponseType(typeof(AuthServiceResponse<object?>), StatusCodes.Status200OK)]
    public async Task<ActionResult<AuthServiceResponse<object?>>> SendOtp(
        [FromBody] SendOtpRequest request,
        CancellationToken cancellationToken)
    {
        var response = await _authService.SendOtpAsync(request, cancellationToken);
        return Ok(response);
    }

    [HttpPost("RefreshAuthentication")]
    [ProducesResponseType(typeof(AuthServiceResponse<AuthSessionEntity>), StatusCodes.Status200OK)]
    public async Task<ActionResult<AuthServiceResponse<AuthSessionEntity>>> RefreshAuthentication(
        [FromBody] RefreshAuthenticationRequest request,
        CancellationToken cancellationToken)
    {
        var response = await _authService.RefreshAuthenticationAsync(request, cancellationToken);
        return Ok(response);
    }

    [HttpPost("Register")]
    [ProducesResponseType(typeof(AuthServiceResponse<AuthSessionEntity>), StatusCodes.Status200OK)]
    public async Task<ActionResult<AuthServiceResponse<AuthSessionEntity>>> Register(
        [FromBody] RegisterRequest request,
        CancellationToken cancellationToken)
    {
        var response = await _authService.RegisterAsync(request, cancellationToken);
        return Ok(response);
    }

    [Authorize]
    [HttpGet("Me")]
    [ProducesResponseType(typeof(AuthServiceResponse<UserProfileEntity>), StatusCodes.Status200OK)]
    public async Task<ActionResult<AuthServiceResponse<UserProfileEntity>>> GetMe(
        CancellationToken cancellationToken)
    {
        var userId = _currentUserService.GetRequiredUserId();
        var response = await _authService.GetMeAsync(userId, cancellationToken);
        return Ok(response);
    }

    [HttpPost("ForgotPassword")]
    [ProducesResponseType(typeof(AuthServiceResponse<object?>), StatusCodes.Status200OK)]
    public async Task<ActionResult<AuthServiceResponse<object?>>> ForgotPassword(
        [FromBody] ForgotPasswordRequest request,
        CancellationToken cancellationToken)
    {
        var response = await _authService.ForgotPasswordAsync(request, cancellationToken);
        return Ok(response);
    }

    [HttpPost("ResetPassword")]
    [ProducesResponseType(typeof(AuthServiceResponse<AuthSessionEntity>), StatusCodes.Status200OK)]
    public async Task<ActionResult<AuthServiceResponse<AuthSessionEntity>>> ResetPassword(
        [FromBody] ResetPasswordRequest request,
        CancellationToken cancellationToken)
    {
        var response = await _authService.ResetPasswordAsync(request, cancellationToken);
        return Ok(response);
    }

    [Authorize]
    [HttpPost("CompleteOnboarding")]
    [ProducesResponseType(typeof(AuthServiceResponse<UserProfileEntity>), StatusCodes.Status200OK)]
    public async Task<ActionResult<AuthServiceResponse<UserProfileEntity>>> CompleteOnboarding(
        CancellationToken cancellationToken)
    {
        var userId = _currentUserService.GetRequiredUserId();
        var response = await _authService.CompleteOnboardingAsync(userId, cancellationToken);
        return Ok(response);
    }

    [Authorize]
    [HttpPost("UploadProfilePhoto")]
    [RequestSizeLimit(5 * 1024 * 1024)]
    [ProducesResponseType(typeof(AuthServiceResponse<UserProfileEntity>), StatusCodes.Status200OK)]
    public async Task<ActionResult<AuthServiceResponse<UserProfileEntity>>> UploadProfilePhoto(
        IFormFile photo,
        CancellationToken cancellationToken)
    {
        if (photo is null || photo.Length == 0)
        {
            return BadRequest(AuthServiceResponse<UserProfileEntity>.Fail(
                400,
                "InvalidPhoto",
                "Profil fotoğrafı seçilmedi."));
        }

        var userId = _currentUserService.GetRequiredUserId();
        await using var stream = photo.OpenReadStream();
        var response = await _authService.UploadProfilePhotoAsync(
            userId,
            stream,
            photo.ContentType,
            photo.Length,
            cancellationToken);

        if (!response.Success)
        {
            return BadRequest(response);
        }

        return Ok(response);
    }
}
