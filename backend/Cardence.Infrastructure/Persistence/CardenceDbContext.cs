using Cardence.Domain.Entities;
using Microsoft.EntityFrameworkCore;

namespace Cardence.Infrastructure.Persistence;

public sealed class CardenceDbContext : DbContext
{
    public CardenceDbContext(DbContextOptions<CardenceDbContext> options)
        : base(options)
    {
    }

    public DbSet<User> Users => Set<User>();
    public DbSet<Card> Cards => Set<Card>();
    public DbSet<SavedCard> SavedCards => Set<SavedCard>();
    public DbSet<WalletEntitlement> WalletEntitlements => Set<WalletEntitlement>();
    public DbSet<AuthRefreshToken> AuthRefreshTokens => Set<AuthRefreshToken>();
    public DbSet<SupportRequest> SupportRequests => Set<SupportRequest>();
    public DbSet<EventGroup> EventGroups => Set<EventGroup>();
    public DbSet<SavedCardEventGroup> SavedCardEventGroups => Set<SavedCardEventGroup>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.ApplyConfigurationsFromAssembly(typeof(CardenceDbContext).Assembly);
        base.OnModelCreating(modelBuilder);
    }
}
