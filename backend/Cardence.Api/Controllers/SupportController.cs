using Cardence.Application.Common;
using Cardence.Application.DTOs.Support;
using Cardence.Application.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace Cardence.Api.Controllers;

[ApiController]
[Authorize]
[Route("")]
[Tags("Support")]
public sealed class SupportController : ControllerBase
{
    private readonly ISupportService _supportService;

    public SupportController(ISupportService supportService)
    {
        _supportService = supportService;
    }

    [HttpPost("SubmitSupportRequest")]
    [ProducesResponseType(typeof(ApiResponse<SupportRequestDto>), StatusCodes.Status201Created)]
    public async Task<ActionResult<ApiResponse<SupportRequestDto>>> SubmitSupportRequest(
        [FromBody] SubmitSupportRequest request,
        CancellationToken cancellationToken)
    {
        var result = await _supportService.SubmitAsync(request, cancellationToken);
        return Created(
            $"/SupportRequests?requestId={result.RequestId}",
            ApiResponse<SupportRequestDto>.Ok(result, HttpContext.TraceIdentifier));
    }
}
