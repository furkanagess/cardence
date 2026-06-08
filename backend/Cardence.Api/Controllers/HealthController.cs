using Cardence.Application.Common;
using Microsoft.AspNetCore.Mvc;

namespace Cardence.Api.Controllers;

[ApiController]
[Route("")]
[Tags("Health")]
public sealed class HealthController : ControllerBase
{
    [HttpGet("Health")]
    [ProducesResponseType(typeof(ApiResponse<HealthResponse>), StatusCodes.Status200OK)]
    public ActionResult<ApiResponse<HealthResponse>> GetHealth()
    {
        var response = ApiResponse<HealthResponse>.Ok(
            new HealthResponse("healthy", "Cardence.Api", DateTime.UtcNow),
            HttpContext.TraceIdentifier);

        return Ok(response);
    }
}

public sealed record HealthResponse(string Status, string Service, DateTime Timestamp);
