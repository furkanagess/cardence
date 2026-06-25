using Cardence.Application.DTOs.NetworkGraph;
using Cardence.Domain.Graph;

namespace Cardence.Application.Interfaces;

/// <summary>
/// Network graph sorgulari. Uygulama: Faz 4.1b.
/// </summary>
public interface INetworkGraphService
{
    Task<NetworkGraphDto> GetGraphAsync(
        NetworkGraphQuery query,
        CancellationToken cancellationToken = default);

    Task<NetworkGraphPathDto> GetPathAsync(
        string fromCardId,
        string toCardId,
        GraphScope scope = GraphScope.Personal,
        CancellationToken cancellationToken = default);
}
