using Cardence.Domain.Entities;

namespace Cardence.Application.Interfaces;

public interface ISupportRequestRepository
{
    Task AddAsync(SupportRequest request, CancellationToken cancellationToken = default);
}
