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

    [AllowAnonymous]
    [HttpPost("Authentication")]
    [ProducesResponseType(typeof(AuthServiceResponse<AuthSessionEntity>), StatusCodes.Status200OK)]
    public async Task<ActionResult<AuthServiceResponse<AuthSessionEntity>>> Authentication(
        [FromBody] AuthenticationRequest request,
        CancellationToken cancellationToken)
    {
        var response = await _authService.AuthenticationAsync(request, cancellationToken);
        return Ok(response);
    }

    [AllowAnonymous]
    [HttpPost("LoginWithPhone")]
    [ProducesResponseType(typeof(AuthServiceResponse<AuthSessionEntity>), StatusCodes.Status200OK)]
    public async Task<ActionResult<AuthServiceResponse<AuthSessionEntity>>> LoginWithPhone(
        [FromBody] LoginWithPhoneRequest request,
        CancellationToken cancellationToken)
    {
        var response = await _authService.LoginWithPhoneAsync(request, cancellationToken);
        return Ok(response);
    }

    [AllowAnonymous]
    [HttpPost("LoginWithEmail")]
    [ProducesResponseType(typeof(AuthServiceResponse<AuthSessionEntity>), StatusCodes.Status200OK)]
    public async Task<ActionResult<AuthServiceResponse<AuthSessionEntity>>> LoginWithEmail(
        [FromBody] LoginWithEmailRequest request,
        CancellationToken cancellationToken)
    {
        var response = await _authService.LoginWithEmailAsync(request, cancellationToken);
        return Ok(response);
    }

    [AllowAnonymous]
    [HttpPost("LoginWithLinkedIn")]
    [ProducesResponseType(typeof(AuthServiceResponse<AuthSessionEntity>), StatusCodes.Status200OK)]
    public async Task<ActionResult<AuthServiceResponse<AuthSessionEntity>>> LoginWithLinkedIn(
        [FromBody] LoginWithLinkedInRequest request,
        CancellationToken cancellationToken)
    {
        var response = await _authService.LoginWithLinkedInAsync(request, cancellationToken);
        return Ok(response);
    }

    [AllowAnonymous]
    [HttpPost("LoginWithGoogle")]
    [ProducesResponseType(typeof(AuthServiceResponse<AuthSessionEntity>), StatusCodes.Status200OK)]
    public async Task<ActionResult<AuthServiceResponse<AuthSessionEntity>>> LoginWithGoogle(
        [FromBody] LoginWithGoogleRequest request,
        CancellationToken cancellationToken)
    {
        var response = await _authService.LoginWithGoogleAsync(request, cancellationToken);
        return Ok(response);
    }

    [AllowAnonymous]
    [HttpPost("LoginWithApple")]
    [ProducesResponseType(typeof(AuthServiceResponse<AuthSessionEntity>), StatusCodes.Status200OK)]
    public async Task<ActionResult<AuthServiceResponse<AuthSessionEntity>>> LoginWithApple(
        [FromBody] LoginWithAppleRequest request,
        CancellationToken cancellationToken)
    {
        var response = await _authService.LoginWithAppleAsync(request, cancellationToken);
        return Ok(response);
    }

    [AllowAnonymous]
    [HttpPost("SendOTP")]
    [ProducesResponseType(typeof(AuthServiceResponse<object?>), StatusCodes.Status200OK)]
    public async Task<ActionResult<AuthServiceResponse<object?>>> SendOtp(
        [FromBody] SendOtpRequest request,
        CancellationToken cancellationToken)
    {
        var response = await _authService.SendOtpAsync(request, cancellationToken);
        return Ok(response);
    }

    [AllowAnonymous]
    [HttpPost("RefreshAuthentication")]
    [ProducesResponseType(typeof(AuthServiceResponse<AuthSessionEntity>), StatusCodes.Status200OK)]
    public async Task<ActionResult<AuthServiceResponse<AuthSessionEntity>>> RefreshAuthentication(
        [FromBody] RefreshAuthenticationRequest request,
        CancellationToken cancellationToken)
    {
        var response = await _authService.RefreshAuthenticationAsync(request, cancellationToken);
        return Ok(response);
    }

    [AllowAnonymous]
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

    [AllowAnonymous]
    [HttpPost("ForgotPassword")]
    [ProducesResponseType(typeof(AuthServiceResponse<object?>), StatusCodes.Status200OK)]
    public async Task<ActionResult<AuthServiceResponse<object?>>> ForgotPassword(
        [FromBody] ForgotPasswordRequest request,
        CancellationToken cancellationToken)
    {
        var response = await _authService.ForgotPasswordAsync(request, cancellationToken);
        return Ok(response);
    }

    [AllowAnonymous]
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
    [Consumes("multipart/form-data")]
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

    [Authorize]
    [HttpDelete("DeleteAccount")]
    [ProducesResponseType(typeof(AuthServiceResponse<object?>), StatusCodes.Status200OK)]
    public async Task<ActionResult<AuthServiceResponse<object?>>> DeleteAccount(
        CancellationToken cancellationToken)
    {
        var userId = _currentUserService.GetRequiredUserId();
        var response = await _authService.DeleteAccountAsync(userId, cancellationToken);
        if (!response.Success)
        {
            return BadRequest(response);
        }

        return Ok(response);
    }
}
