using Cardence.Domain.Entities;

namespace Cardence.Application.Interfaces;

public interface IPasswordResetTokenRepository
{
    Task AddAsync(PasswordResetToken token, CancellationToken cancellationToken = default);

    Task<PasswordResetToken?> GetValidByTokenHashAsync(
        string tokenHash,
        CancellationToken cancellationToken = default);

    Task InvalidateActiveTokensAsync(Guid userId, CancellationToken cancellationToken = default);

    Task UpdateAsync(PasswordResetToken token, CancellationToken cancellationToken = default);
}
