using Cardence.Domain.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace Cardence.Infrastructure.Persistence.Configurations;

public sealed class WalletEntitlementConfiguration : IEntityTypeConfiguration<WalletEntitlement>
{
    public void Configure(EntityTypeBuilder<WalletEntitlement> builder)
    {
        builder.ToTable("wallet_entitlements");

        builder.HasKey(x => x.UserId);

        builder.Property(x => x.Tier).HasMaxLength(20).HasColumnName("tier");
        builder.Property(x => x.MaxCards).HasColumnName("max_cards");
        builder.Property(x => x.UpdatedAt).HasColumnName("updated_at");

        builder.HasOne(x => x.User)
            .WithOne()
            .HasForeignKey<WalletEntitlement>(x => x.UserId)
            .OnDelete(DeleteBehavior.Cascade);
    }
}
