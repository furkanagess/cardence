using Cardence.Application.Common;
using Cardence.Application.DTOs.NetworkGraph;
using Cardence.Application.Interfaces;
using Cardence.Domain.Graph;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace Cardence.Api.Controllers;

[ApiController]
[Authorize]
[Route("")]
[Tags("Network Graph")]
public sealed class NetworkGraphController : ControllerBase
{
    private readonly INetworkGraphService _networkGraphService;

    public NetworkGraphController(INetworkGraphService networkGraphService)
    {
        _networkGraphService = networkGraphService;
    }

    [HttpGet("NetworkGraph")]
    [ProducesResponseType(typeof(ApiResponse<NetworkGraphDto>), StatusCodes.Status200OK)]
    public async Task<ActionResult<ApiResponse<NetworkGraphDto>>> GetNetworkGraph(
        [FromQuery] GraphScope scope = GraphScope.Personal,
        [FromQuery] Guid? eventGroupId = null,
        [FromQuery] Guid? organizationId = null,
        [FromQuery] Guid? organizationEventId = null,
        [FromQuery] string? centerCardId = null,
        [FromQuery] int maxDepth = 2,
        [FromQuery] int maxNodes = 100,
        CancellationToken cancellationToken = default)
    {
        var graph = await _networkGraphService.GetGraphAsync(
            new NetworkGraphQuery
            {
                Scope = scope,
                EventGroupId = eventGroupId,
                OrganizationId = organizationId,
                OrganizationEventId = organizationEventId,
                CenterCardId = centerCardId,
                MaxDepth = maxDepth,
                MaxNodes = maxNodes,
            },
            cancellationToken);

        return Ok(ApiResponse<NetworkGraphDto>.Ok(graph, HttpContext.TraceIdentifier));
    }

    [HttpGet("NetworkGraphPath")]
    [ProducesResponseType(typeof(ApiResponse<NetworkGraphPathDto>), StatusCodes.Status200OK)]
    public async Task<ActionResult<ApiResponse<NetworkGraphPathDto>>> GetNetworkGraphPath(
        [FromQuery] string fromCardId,
        [FromQuery] string toCardId,
        [FromQuery] GraphScope scope = GraphScope.Personal,
        CancellationToken cancellationToken = default)
    {
        var path = await _networkGraphService.GetPathAsync(
            fromCardId,
            toCardId,
            scope,
            cancellationToken);

        return Ok(ApiResponse<NetworkGraphPathDto>.Ok(path, HttpContext.TraceIdentifier));
    }
}
