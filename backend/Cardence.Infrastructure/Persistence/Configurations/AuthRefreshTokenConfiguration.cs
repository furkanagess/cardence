using Cardence.Domain.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace Cardence.Infrastructure.Persistence.Configurations;

public sealed class AuthRefreshTokenConfiguration : IEntityTypeConfiguration<AuthRefreshToken>
{
    public void Configure(EntityTypeBuilder<AuthRefreshToken> builder)
    {
        builder.ToTable("auth_refresh_tokens");

        builder.HasKey(x => x.Id);

        builder.Property(x => x.UserId).HasColumnName("user_id");
        builder.Property(x => x.Token).HasMaxLength(512).HasColumnName("token");
        builder.Property(x => x.ExpiresAtUtc).HasColumnName("expires_at_utc");
        builder.Property(x => x.CreatedAtUtc).HasColumnName("created_at_utc");

        builder.HasIndex(x => x.Token).IsUnique();
        builder.HasIndex(x => x.UserId);

        builder.HasOne(x => x.User)
            .WithMany()
            .HasForeignKey(x => x.UserId)
            .OnDelete(DeleteBehavior.Cascade);
    }
}
