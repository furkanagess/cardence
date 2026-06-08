using System.Text.Json;
using Cardence.Application.Common;
using Cardence.Application.DTOs.Wallet;
using Cardence.Application.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace Cardence.Api.Controllers;

[ApiController]
[Authorize]
[Route("")]
[Tags("Wallet")]
public sealed class SavedCardsController : ControllerBase
{
    private readonly ISavedCardService _savedCardService;

    public SavedCardsController(ISavedCardService savedCardService)
    {
        _savedCardService = savedCardService;
    }

    [HttpGet("SavedCards")]
    [ProducesResponseType(typeof(ApiResponse<IReadOnlyList<SavedCardDto>>), StatusCodes.Status200OK)]
    public async Task<ActionResult<ApiResponse<IReadOnlyList<SavedCardDto>>>> GetSavedCards(
        CancellationToken cancellationToken)
    {
        var cards = await _savedCardService.GetAllAsync(cancellationToken);
        return Ok(ApiResponse<IReadOnlyList<SavedCardDto>>.Ok(cards, HttpContext.TraceIdentifier));
    }

    [HttpPost("SaveSavedCard")]
    [ProducesResponseType(typeof(ApiResponse<SavedCardDto>), StatusCodes.Status201Created)]
    public async Task<ActionResult<ApiResponse<SavedCardDto>>> SaveSavedCard(
        [FromBody] JsonElement body,
        CancellationToken cancellationToken)
    {
        var card = await _savedCardService.CreateFromJsonAsync(body, cancellationToken);
        return Created(
            $"/SavedCards?cardId={Uri.EscapeDataString(card.CardId)}",
            ApiResponse<SavedCardDto>.Ok(card, HttpContext.TraceIdentifier));
    }

    [HttpPut("UpdateSavedCard")]
    [ProducesResponseType(typeof(ApiResponse<SavedCardDto>), StatusCodes.Status200OK)]
    public async Task<ActionResult<ApiResponse<SavedCardDto>>> UpdateSavedCard(
        [FromBody] SavedCardDto request,
        CancellationToken cancellationToken)
    {
        if (string.IsNullOrWhiteSpace(request.CardId))
        {
            return BadRequest(ApiResponse<SavedCardDto>.Fail(
                ErrorCodes.ValidationError,
                "CardId is required.",
                traceId: HttpContext.TraceIdentifier));
        }

        var card = await _savedCardService.UpdateAsync(request, cancellationToken);
        return Ok(ApiResponse<SavedCardDto>.Ok(card, HttpContext.TraceIdentifier));
    }

    [HttpDelete("DeleteSavedCard")]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    public async Task<IActionResult> DeleteSavedCard(
        [FromQuery] string cardId,
        CancellationToken cancellationToken)
    {
        await _savedCardService.DeleteAsync(cardId, cancellationToken);
        return NoContent();
    }

    [HttpGet("WalletQuota")]
    [ProducesResponseType(typeof(ApiResponse<WalletQuotaDto>), StatusCodes.Status200OK)]
    public async Task<ActionResult<ApiResponse<WalletQuotaDto>>> GetWalletQuota(
        CancellationToken cancellationToken)
    {
        var quota = await _savedCardService.GetWalletQuotaAsync(cancellationToken);
        return Ok(ApiResponse<WalletQuotaDto>.Ok(quota, HttpContext.TraceIdentifier));
    }
}
