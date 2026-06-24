using Cardence.Domain.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace Cardence.Infrastructure.Persistence.Configurations;

public sealed class UserAuthProviderConfiguration : IEntityTypeConfiguration<UserAuthProvider>
{
    public void Configure(EntityTypeBuilder<UserAuthProvider> builder)
    {
        builder.ToTable("user_auth_providers");

        builder.HasKey(x => new { x.ProviderId, x.ProviderUserId });

        builder.Property(x => x.ProviderId)
            .HasMaxLength(50)
            .HasColumnName("provider_id");

        builder.Property(x => x.ProviderUserId)
            .HasMaxLength(200)
            .HasColumnName("provider_user_id");

        builder.Property(x => x.UserId).HasColumnName("user_id");

        builder.HasIndex(x => x.UserId)
            .HasDatabaseName("ix_user_auth_providers_user_id");

        builder.HasOne(x => x.User)
            .WithMany(x => x.AuthProviders)
            .HasForeignKey(x => x.UserId)
            .OnDelete(DeleteBehavior.Cascade);
    }
}
