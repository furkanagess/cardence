using Cardence.Application.Common;
using Cardence.Application.DTOs.Plans;
using Cardence.Application.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace Cardence.Api.Controllers;

[ApiController]
[Authorize]
[Route("")]
[Tags("Plans")]
public sealed class PlanEntitlementsController : ControllerBase
{
    private readonly IPlanPolicyService _planPolicyService;

    public PlanEntitlementsController(IPlanPolicyService planPolicyService)
    {
        _planPolicyService = planPolicyService;
    }

    [HttpGet("PlanEntitlements")]
    [ProducesResponseType(typeof(ApiResponse<PlanEntitlementsDto>), StatusCodes.Status200OK)]
    public async Task<ActionResult<ApiResponse<PlanEntitlementsDto>>> GetPlanEntitlements(
        CancellationToken cancellationToken)
    {
        var entitlements = await _planPolicyService.GetEntitlementsAsync(cancellationToken);
        return Ok(ApiResponse<PlanEntitlementsDto>.Ok(
            entitlements,
            HttpContext.TraceIdentifier));
    }
}
