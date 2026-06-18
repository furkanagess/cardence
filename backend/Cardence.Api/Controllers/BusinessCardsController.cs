using Cardence.Application.Common;
using Cardence.Application.DTOs.Cards;
using Cardence.Application.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace Cardence.Api.Controllers;

[ApiController]
[Authorize]
[Route("")]
[Tags("BusinessCards")]
public sealed class BusinessCardsController : ControllerBase
{
    private readonly IBusinessCardService _businessCardService;

    public BusinessCardsController(IBusinessCardService businessCardService)
    {
        _businessCardService = businessCardService;
    }

    [HttpGet("BusinessCards")]
    [ProducesResponseType(typeof(ApiResponse<IReadOnlyList<BusinessCardDto>>), StatusCodes.Status200OK)]
    public async Task<ActionResult<ApiResponse<IReadOnlyList<BusinessCardDto>>>> GetBusinessCards(
        CancellationToken cancellationToken)
    {
        var cards = await _businessCardService.GetAllAsync(cancellationToken);
        return Ok(ApiResponse<IReadOnlyList<BusinessCardDto>>.Ok(cards, HttpContext.TraceIdentifier));
    }

    [HttpGet("BusinessCard")]
    [ProducesResponseType(typeof(ApiResponse<BusinessCardDto>), StatusCodes.Status200OK)]
    public async Task<ActionResult<ApiResponse<BusinessCardDto>>> GetBusinessCard(
        [FromQuery] string cardId,
        CancellationToken cancellationToken)
    {
        var card = await _businessCardService.GetByCardIdAsync(cardId, cancellationToken);
        return Ok(ApiResponse<BusinessCardDto>.Ok(card, HttpContext.TraceIdentifier));
    }

    [HttpPost("SaveBusinessCard")]
    [ProducesResponseType(typeof(ApiResponse<BusinessCardDto>), StatusCodes.Status201Created)]
    public async Task<ActionResult<ApiResponse<BusinessCardDto>>> SaveBusinessCard(
        [FromBody] BusinessCardDto request,
        CancellationToken cancellationToken)
    {
        var card = await _businessCardService.CreateAsync(request, cancellationToken);
        return CreatedAtAction(
            nameof(GetBusinessCard),
            new { cardId = card.CardId },
            ApiResponse<BusinessCardDto>.Ok(card, HttpContext.TraceIdentifier));
    }

    [HttpPut("UpdateBusinessCard")]
    [ProducesResponseType(typeof(ApiResponse<BusinessCardDto>), StatusCodes.Status200OK)]
    public async Task<ActionResult<ApiResponse<BusinessCardDto>>> UpdateBusinessCard(
        [FromBody] BusinessCardDto request,
        CancellationToken cancellationToken)
    {
        if (string.IsNullOrWhiteSpace(request.CardId))
        {
            return BadRequest(ApiResponse<BusinessCardDto>.Fail(
                ErrorCodes.ValidationError,
                "CardId is required.",
                traceId: HttpContext.TraceIdentifier));
        }

        var card = await _businessCardService.UpsertAsync(request.CardId, request, cancellationToken);
        return Ok(ApiResponse<BusinessCardDto>.Ok(card, HttpContext.TraceIdentifier));
    }

    [HttpDelete("DeleteBusinessCard")]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    public async Task<IActionResult> DeleteBusinessCard(
        [FromQuery] string cardId,
        CancellationToken cancellationToken)
    {
        await _businessCardService.DeleteAsync(cardId, cancellationToken);
        return NoContent();
    }

    [HttpGet("ProfileStats")]
    [ProducesResponseType(typeof(ApiResponse<ProfileStatsDto>), StatusCodes.Status200OK)]
    public async Task<ActionResult<ApiResponse<ProfileStatsDto>>> GetProfileStats(
        CancellationToken cancellationToken)
    {
        var stats = await _businessCardService.GetProfileStatsAsync(cancellationToken);
        return Ok(ApiResponse<ProfileStatsDto>.Ok(stats, HttpContext.TraceIdentifier));
    }

    [HttpGet("BusinessCardShare")]
    [ProducesResponseType(typeof(ApiResponse<IReadOnlyDictionary<string, object?>>), StatusCodes.Status200OK)]
    public async Task<ActionResult<ApiResponse<IReadOnlyDictionary<string, object?>>>> GetBusinessCardShare(
        [FromQuery] string cardId,
        CancellationToken cancellationToken)
    {
        var payload = await _businessCardService.GetSharePayloadAsync(cardId, cancellationToken);
        return Ok(ApiResponse<IReadOnlyDictionary<string, object?>>.Ok(payload, HttpContext.TraceIdentifier));
    }
}
