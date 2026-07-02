using Cardence.Application.Common;
using Cardence.Application.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace Cardence.Api.Controllers;

[ApiController]
[AllowAnonymous]
[Route("")]
[Tags("PublicCards")]
public sealed class PublicCardsController : ControllerBase
{
    private readonly IBusinessCardService _businessCardService;

    public PublicCardsController(IBusinessCardService businessCardService)
    {
        _businessCardService = businessCardService;
    }

    [HttpGet("PublicBusinessCardShare")]
    [ProducesResponseType(typeof(ApiResponse<IReadOnlyDictionary<string, object?>>), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(ApiResponse<object?>), StatusCodes.Status404NotFound)]
    public async Task<ActionResult<ApiResponse<IReadOnlyDictionary<string, object?>>>> GetPublicBusinessCardShare(
        [FromQuery] string cardId,
        CancellationToken cancellationToken)
    {
        var payload = await _businessCardService.GetPublicSharePayloadAsync(cardId, cancellationToken);
        return Ok(ApiResponse<IReadOnlyDictionary<string, object?>>.Ok(payload, HttpContext.TraceIdentifier));
    }

    [HttpPost("PublicBusinessCardContactClick")]
    [ProducesResponseType(typeof(ApiResponse<object?>), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(ApiResponse<object?>), StatusCodes.Status404NotFound)]
    public async Task<ActionResult<ApiResponse<object?>>> TrackPublicBusinessCardContactClick(
        [FromQuery] string cardId,
        [FromQuery] string contactType,
        CancellationToken cancellationToken)
    {
        await _businessCardService.RecordPublicContactClickAsync(
            cardId,
            contactType,
            cancellationToken);
        return Ok(ApiResponse<object?>.Ok(null, HttpContext.TraceIdentifier));
    }

    [HttpHead("PublicBusinessCard")]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> PublicBusinessCardExists(
        [FromQuery] string cardId,
        CancellationToken cancellationToken)
    {
        var exists = await _businessCardService.PublicCardExistsAsync(cardId, cancellationToken);
        return exists ? NoContent() : NotFound();
    }
}
