using Cardence.Application.Interfaces;
using Cardence.Domain.Entities;
using Cardence.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;

namespace Cardence.Infrastructure.Repositories;

public sealed class SupportRequestRepository : ISupportRequestRepository
{
    private readonly CardenceDbContext _dbContext;

    public SupportRequestRepository(CardenceDbContext dbContext)
    {
        _dbContext = dbContext;
    }

    public async Task AddAsync(SupportRequest request, CancellationToken cancellationToken = default)
    {
        _dbContext.SupportRequests.Add(request);
        await _dbContext.SaveChangesAsync(cancellationToken);
    }
}
