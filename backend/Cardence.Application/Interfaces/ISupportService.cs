using Cardence.Application.DTOs.Support;

namespace Cardence.Application.Interfaces;

public interface ISupportService
{
    Task<SupportRequestDto> SubmitAsync(
        SubmitSupportRequest request,
        CancellationToken cancellationToken = default);
}
