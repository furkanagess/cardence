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
    public DbSet<UserAuthProvider> UserAuthProviders => Set<UserAuthProvider>();
    public DbSet<SupportRequest> SupportRequests => Set<SupportRequest>();
    public DbSet<EventGroup> EventGroups => Set<EventGroup>();
    public DbSet<SavedCardEventGroup> SavedCardEventGroups => Set<SavedCardEventGroup>();
    public DbSet<EventGroupCardInvite> EventGroupCardInvites => Set<EventGroupCardInvite>();
    public DbSet<SubscriptionEvent> SubscriptionEvents => Set<SubscriptionEvent>();
    public DbSet<CardInteraction> CardInteractions => Set<CardInteraction>();
    public DbSet<PasswordResetToken> PasswordResetTokens => Set<PasswordResetToken>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.ApplyConfigurationsFromAssembly(typeof(CardenceDbContext).Assembly);
        base.OnModelCreating(modelBuilder);
    }
}
