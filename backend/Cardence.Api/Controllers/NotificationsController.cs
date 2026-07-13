using Cardence.Application.DTOs.Auth;
using Cardence.Application.DTOs.Notifications;
using Cardence.Application.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace Cardence.Api.Controllers;

[ApiController]
[Route("")]
[Tags("Notifications")]
public sealed class NotificationsController : ControllerBase
{
    private readonly IPushNotificationService _pushNotificationService;

    public NotificationsController(IPushNotificationService pushNotificationService)
    {
        _pushNotificationService = pushNotificationService;
    }

    [Authorize]
    [HttpPost("RegisterPushToken")]
    [ProducesResponseType(typeof(AuthServiceResponse<object?>), StatusCodes.Status200OK)]
    public async Task<ActionResult<AuthServiceResponse<object?>>> RegisterPushToken(
        [FromBody] RegisterPushTokenRequest request,
        CancellationToken cancellationToken)
    {
        await _pushNotificationService.RegisterDeviceTokenAsync(request, cancellationToken);
        return Ok(AuthServiceResponse<object?>.Ok(null));
    }

    [Authorize]
    [HttpDelete("UnregisterPushToken")]
    [ProducesResponseType(typeof(AuthServiceResponse<object?>), StatusCodes.Status200OK)]
    public async Task<ActionResult<AuthServiceResponse<object?>>> UnregisterPushToken(
        [FromBody] RegisterPushTokenRequest request,
        CancellationToken cancellationToken)
    {
        await _pushNotificationService.UnregisterDeviceTokenAsync(
            request.Token,
            cancellationToken);
        return Ok(AuthServiceResponse<object?>.Ok(null));
    }
}
