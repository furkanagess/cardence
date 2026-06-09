using Cardence.Domain.Constants;
using Cardence.Domain.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace Cardence.Infrastructure.Persistence.Configurations;

public sealed class BusinessCardConfiguration : IEntityTypeConfiguration<BusinessCard>
{
    public void Configure(EntityTypeBuilder<BusinessCard> builder)
    {
        builder.ToTable("business_cards");

        builder.HasKey(x => x.Id);

        builder.Property(x => x.UserId).HasColumnName("user_id");
        builder.Property(x => x.CardId).HasMaxLength(BusinessCardConstants.CardIdLength).HasColumnName("card_id");
        builder.Property(x => x.CardName).HasMaxLength(200).HasColumnName("card_name");
        builder.Property(x => x.DisplayName).HasMaxLength(200).HasColumnName("display_name");
        builder.Property(x => x.Email).HasMaxLength(320).HasColumnName("email");
        builder.Property(x => x.Phone).HasMaxLength(20).HasColumnName("phone");
        builder.Property(x => x.Company).HasMaxLength(200).HasColumnName("company");
        builder.Property(x => x.Title).HasMaxLength(200).HasColumnName("title");
        builder.Property(x => x.Website).HasMaxLength(500).HasColumnName("website");
        builder.Property(x => x.Linkedin).HasMaxLength(500).HasColumnName("linkedin");
        builder.Property(x => x.Skills).HasColumnName("skills");
        builder.Property(x => x.School).HasMaxLength(200).HasColumnName("school");
        builder.Property(x => x.About).HasColumnName("about");
        builder.Property(x => x.AccentColor).HasMaxLength(7).HasColumnName("accent_color");
        builder.Property(x => x.BackgroundColor).HasMaxLength(7).HasColumnName("background_color");
        builder.Property(x => x.LastUsedPaletteBackgroundColor)
            .HasMaxLength(7)
            .HasColumnName("last_used_palette_background_color");
        builder.Property(x => x.CreatedAt).HasColumnName("created_at");
        builder.Property(x => x.UpdatedAt).HasColumnName("updated_at");

        builder.HasIndex(x => x.CardId).IsUnique();
        builder.HasIndex(x => new { x.UserId, x.CardId });

        builder.HasOne(x => x.User)
            .WithMany(x => x.BusinessCards)
            .HasForeignKey(x => x.UserId)
            .OnDelete(DeleteBehavior.Cascade);
    }
}
