using Cardence.Domain.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace Cardence.Infrastructure.Persistence.Configurations;

public sealed class UserConfiguration : IEntityTypeConfiguration<User>
{
    public void Configure(EntityTypeBuilder<User> builder)
    {
        builder.ToTable("users");

        builder.HasKey(x => x.Id);

        builder.Property(x => x.DisplayName).HasMaxLength(200).HasColumnName("display_name");
        builder.Property(x => x.Email).HasMaxLength(320).HasColumnName("email");
        builder.Property(x => x.Phone).HasMaxLength(20).HasColumnName("phone");
        builder.Property(x => x.PhotoUrl).HasMaxLength(2048).HasColumnName("photo_url");
        builder.Property(x => x.PasswordHash).HasMaxLength(512).HasColumnName("password_hash");
        builder.Property(x => x.OnboardingCompleted).HasColumnName("onboarding_completed");
        builder.Property(x => x.CreatedAt).HasColumnName("created_at");
        builder.Property(x => x.UpdatedAt).HasColumnName("updated_at");

        builder.HasIndex(x => x.Email)
            .IsUnique()
            .HasDatabaseName("ix_users_email");

        builder.HasIndex(x => x.Phone)
            .IsUnique()
            .HasDatabaseName("ix_users_phone")
            .HasFilter("phone IS NOT NULL AND phone <> ''");
    }
}
