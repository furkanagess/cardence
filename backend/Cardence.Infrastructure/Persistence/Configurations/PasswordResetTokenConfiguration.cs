using Cardence.Domain.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace Cardence.Infrastructure.Persistence.Configurations;

public sealed class PasswordResetTokenConfiguration : IEntityTypeConfiguration<PasswordResetToken>
{
    public void Configure(EntityTypeBuilder<PasswordResetToken> builder)
    {
        builder.ToTable("password_reset_tokens");

        builder.HasKey(x => x.Id);

        builder.Property(x => x.UserId).HasColumnName("user_id");
        builder.Property(x => x.TokenHash).HasMaxLength(128).HasColumnName("token_hash");
        builder.Property(x => x.ExpiresAt).HasColumnName("expires_at");
        builder.Property(x => x.UsedAt).HasColumnName("used_at");
        builder.Property(x => x.CreatedAt).HasColumnName("created_at");
        builder.Property(x => x.RequestedIp).HasMaxLength(64).HasColumnName("requested_ip");
        builder.Property(x => x.UserAgent).HasMaxLength(512).HasColumnName("user_agent");

        builder.HasIndex(x => x.TokenHash)
            .IsUnique()
            .HasDatabaseName("ix_password_reset_tokens_token_hash");

        builder.HasIndex(x => new { x.UserId, x.ExpiresAt })
            .HasDatabaseName("ix_password_reset_tokens_user_id_expires_at");

        builder.HasOne(x => x.User)
            .WithMany(x => x.PasswordResetTokens)
            .HasForeignKey(x => x.UserId)
            .OnDelete(DeleteBehavior.Cascade);
    }
}
