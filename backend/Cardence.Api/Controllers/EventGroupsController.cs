using System.Text.Json;
using Cardence.Application.Common;
using Cardence.Application.DTOs.EventGroups;
using Cardence.Application.DTOs.Wallet;
using Cardence.Application.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace Cardence.Api.Controllers;

[ApiController]
[Authorize]
[Route("")]
[Tags("EventGroups")]
public sealed class EventGroupsController : ControllerBase
{
    private static readonly JsonSerializerOptions FormJsonOptions = new()
    {
        PropertyNameCaseInsensitive = true,
    };

    private readonly IEventGroupService _eventGroupService;

    public EventGroupsController(IEventGroupService eventGroupService)
    {
        _eventGroupService = eventGroupService;
    }

    [HttpGet("EventGroups")]
    [ProducesResponseType(typeof(ApiResponse<IReadOnlyList<EventGroupDto>>), StatusCodes.Status200OK)]
    public async Task<ActionResult<ApiResponse<IReadOnlyList<EventGroupDto>>>> GetEventGroups(
        CancellationToken cancellationToken)
    {
        var groups = await _eventGroupService.GetAllAsync(cancellationToken);
        return Ok(ApiResponse<IReadOnlyList<EventGroupDto>>.Ok(groups, HttpContext.TraceIdentifier));
    }

    [HttpPost("SaveEventGroup")]
    [RequestSizeLimit(6 * 1024 * 1024)]
    [ProducesResponseType(typeof(ApiResponse<EventGroupDto>), StatusCodes.Status201Created)]
    public async Task<ActionResult<ApiResponse<EventGroupDto>>> SaveEventGroup(
        CancellationToken cancellationToken)
    {
        EventGroupDto group;
        if (Request.HasFormContentType)
        {
            var form = await Request.ReadFormAsync(cancellationToken);
            var requestJson = form["request"].ToString();
            if (string.IsNullOrWhiteSpace(requestJson))
            {
                return BadRequest(ApiResponse<EventGroupDto>.Fail(
                    "InvalidRequest",
                    "Etkinlik bilgileri gönderilmedi.",
                    traceId: HttpContext.TraceIdentifier));
            }

            SaveEventGroupRequest request;
            try
            {
                request = JsonSerializer.Deserialize<SaveEventGroupRequest>(
                        requestJson,
                        FormJsonOptions)
                    ?? throw new JsonException("Request body is empty.");
            }
            catch (JsonException)
            {
                return BadRequest(ApiResponse<EventGroupDto>.Fail(
                    "InvalidRequest",
                    "Etkinlik bilgileri okunamadı.",
                    traceId: HttpContext.TraceIdentifier));
            }

            var photo = form.Files.GetFile("photo");
            if (photo is { Length: > 0 })
            {
                await using var stream = photo.OpenReadStream();
                group = await _eventGroupService.CreateAsync(
                    request,
                    stream,
                    photo.ContentType,
                    photo.Length,
                    cancellationToken);
            }
            else
            {
                group = await _eventGroupService.CreateAsync(
                    request,
                    cancellationToken: cancellationToken);
            }
        }
        else
        {
            var request = await Request.ReadFromJsonAsync<SaveEventGroupRequest>(
                cancellationToken);
            if (request is null)
            {
                return BadRequest(ApiResponse<EventGroupDto>.Fail(
                    "InvalidRequest",
                    "Etkinlik bilgileri gönderilmedi.",
                    traceId: HttpContext.TraceIdentifier));
            }

            group = await _eventGroupService.CreateAsync(
                request,
                cancellationToken: cancellationToken);
        }

        return Created(
            $"/EventGroups?id={Uri.EscapeDataString(group.Id)}",
            ApiResponse<EventGroupDto>.Ok(group, HttpContext.TraceIdentifier));
    }

    [HttpPut("UpdateEventGroup")]
    [ProducesResponseType(typeof(ApiResponse<EventGroupDto>), StatusCodes.Status200OK)]
    public async Task<ActionResult<ApiResponse<EventGroupDto>>> UpdateEventGroup(
        [FromBody] UpdateEventGroupRequest request,
        CancellationToken cancellationToken)
    {
        var group = await _eventGroupService.UpdateAsync(request, cancellationToken);
        return Ok(ApiResponse<EventGroupDto>.Ok(group, HttpContext.TraceIdentifier));
    }

    [HttpDelete("DeleteEventGroup")]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    public async Task<IActionResult> DeleteEventGroup(
        [FromQuery] string id,
        CancellationToken cancellationToken)
    {
        await _eventGroupService.DeleteAsync(id, cancellationToken);
        return NoContent();
    }

    [HttpPost("UploadEventGroupPhoto")]
    [RequestSizeLimit(5 * 1024 * 1024)]
    [ProducesResponseType(typeof(ApiResponse<EventGroupDto>), StatusCodes.Status200OK)]
    public async Task<ActionResult<ApiResponse<EventGroupDto>>> UploadEventGroupPhoto(
        [FromQuery] string id,
        [FromForm] IFormFile photo,
        CancellationToken cancellationToken)
    {
        if (photo is null || photo.Length == 0)
        {
            return BadRequest(ApiResponse<EventGroupDto>.Fail(
                "InvalidPhoto",
                "Etkinlik fotoğrafı seçilmedi.",
                traceId: HttpContext.TraceIdentifier));
        }

        await using var stream = photo.OpenReadStream();
        var group = await _eventGroupService.UploadPhotoAsync(
            id,
            stream,
            photo.ContentType,
            photo.Length,
            cancellationToken);
        return Ok(ApiResponse<EventGroupDto>.Ok(group, HttpContext.TraceIdentifier));
    }

    [HttpPost("InviteEventGroupCardsByCardId")]
    [ProducesResponseType(typeof(ApiResponse<EventGroupDto>), StatusCodes.Status200OK)]
    public async Task<ActionResult<ApiResponse<EventGroupDto>>> InviteEventGroupCardsByCardId(
        [FromBody] InviteEventGroupCardsByCardIdRequest request,
        CancellationToken cancellationToken)
    {
        var group = await _eventGroupService.InviteCardsByCardIdAsync(request, cancellationToken);
        return Ok(ApiResponse<EventGroupDto>.Ok(group, HttpContext.TraceIdentifier));
    }

    [HttpGet("EventGroupInvitations")]
    [ProducesResponseType(typeof(ApiResponse<IReadOnlyList<EventGroupInvitationDto>>), StatusCodes.Status200OK)]
    public async Task<ActionResult<ApiResponse<IReadOnlyList<EventGroupInvitationDto>>>> GetEventGroupInvitations(
        CancellationToken cancellationToken)
    {
        var invitations = await _eventGroupService.GetPendingInvitationsAsync(cancellationToken);
        return Ok(ApiResponse<IReadOnlyList<EventGroupInvitationDto>>.Ok(
            invitations,
            HttpContext.TraceIdentifier));
    }

    [HttpPost("AcceptEventGroupInvitation")]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    public async Task<IActionResult> AcceptEventGroupInvitation(
        [FromBody] RespondEventGroupInvitationRequest request,
        CancellationToken cancellationToken)
    {
        await _eventGroupService.AcceptInvitationAsync(request, cancellationToken);
        return NoContent();
    }

    [HttpPost("RejectEventGroupInvitation")]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    public async Task<IActionResult> RejectEventGroupInvitation(
        [FromBody] RespondEventGroupInvitationRequest request,
        CancellationToken cancellationToken)
    {
        await _eventGroupService.RejectInvitationAsync(request, cancellationToken);
        return NoContent();
    }

    [HttpPost("LinkEventGroupCards")]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    public async Task<IActionResult> LinkEventGroupCards(
        [FromBody] LinkEventGroupCardsRequest request,
        CancellationToken cancellationToken)
    {
        await _eventGroupService.LinkCardsAsync(request, cancellationToken);
        return NoContent();
    }

    [HttpDelete("UnlinkEventGroupCard")]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    public async Task<IActionResult> UnlinkEventGroupCard(
        [FromQuery] string id,
        [FromQuery] string cardId,
        CancellationToken cancellationToken)
    {
        await _eventGroupService.UnlinkCardAsync(id, cardId, cancellationToken);
        return NoContent();
    }

    [HttpGet("EventGroupCards")]
    [ProducesResponseType(typeof(ApiResponse<IReadOnlyList<SavedCardDto>>), StatusCodes.Status200OK)]
    public async Task<ActionResult<ApiResponse<IReadOnlyList<SavedCardDto>>>> GetEventGroupCards(
        [FromQuery] string id,
        CancellationToken cancellationToken)
    {
        var cards = await _eventGroupService.GetCardsAsync(id, cancellationToken);
        return Ok(ApiResponse<IReadOnlyList<SavedCardDto>>.Ok(cards, HttpContext.TraceIdentifier));
    }
}
