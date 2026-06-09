using Cardence.Application.Health;

namespace Cardence.Application.Interfaces;

public interface IHealthStatusReader
{
    Task<SystemHealthSnapshot> ReadAsync(bool includeTableCounts, CancellationToken cancellationToken = default);
}
