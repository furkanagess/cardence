using Cardence.Domain.Constants;
using Cardence.Domain.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace Cardence.Infrastructure.Persistence.Configurations;

public sealed class EventGroupWalletCardConfiguration
    : IEntityTypeConfiguration<EventGroupWalletCard>
{
    public void Configure(EntityTypeBuilder<EventGroupWalletCard> builder)
    {
        builder.ToTable("event_group_wallet_cards");

        builder.HasKey(x => new { x.UserId, x.CardId, x.EventGroupId });

        builder.Property(x => x.UserId).HasColumnName("user_id");
        builder.Property(x => x.CardId)
            .HasMaxLength(BusinessCardConstants.CardIdLength)
            .HasColumnName("card_id");
        builder.Property(x => x.EventGroupId).HasColumnName("event_group_id");

        builder.HasIndex(x => x.EventGroupId);
        builder.HasIndex(x => new { x.UserId, x.CardId });

        builder.HasOne(x => x.User)
            .WithMany()
            .HasForeignKey(x => x.UserId)
            .OnDelete(DeleteBehavior.Cascade);

        builder.HasOne(x => x.EventGroup)
            .WithMany(x => x.WalletCardLinks)
            .HasForeignKey(x => x.EventGroupId)
            .OnDelete(DeleteBehavior.Cascade);
    }
}