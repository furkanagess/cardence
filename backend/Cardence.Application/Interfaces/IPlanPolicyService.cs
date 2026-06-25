using Cardence.Application.DTOs.Plans;

namespace Cardence.Application.Interfaces;

public interface IPlanPolicyService
{
    Task<PlanEntitlementsDto> GetEntitlementsAsync(CancellationToken cancellationToken = default);
}
