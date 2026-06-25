using System.Text.Json;
using Cardence.Application.Common;
using Cardence.Application.DTOs.Subscriptions;
using Cardence.Application.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace Cardence.Api.Controllers;

[ApiController]
[AllowAnonymous]
[Route("")]
[Tags("Subscriptions")]
public sealed class RevenueCatWebhookController : ControllerBase
{
    private readonly IRevenueCatWebhookService _webhookService;

    public RevenueCatWebhookController(IRevenueCatWebhookService webhookService)
    {
        _webhookService = webhookService;
    }

    [HttpPost("RevenueCatWebhook")]
    [ProducesResponseType(typeof(ApiResponse<RevenueCatWebhookResultDto>), StatusCodes.Status200OK)]
    public async Task<ActionResult<ApiResponse<RevenueCatWebhookResultDto>>> Receive(
        [FromBody] JsonElement body,
        CancellationToken cancellationToken)
    {
        var result = await _webhookService.ProcessAsync(
            body,
            Request.Headers.Authorization.ToString(),
            Request.Headers["X-RevenueCat-Auth"].ToString(),
            cancellationToken);

        return Ok(ApiResponse<RevenueCatWebhookResultDto>.Ok(
            result,
            HttpContext.TraceIdentifier));
    }
}
