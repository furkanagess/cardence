using Cardence.Domain.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace Cardence.Infrastructure.Persistence.Configurations;

public sealed class CardEventGroupConfiguration : IEntityTypeConfiguration<CardEventGroup>
{
    public void Configure(EntityTypeBuilder<CardEventGroup> builder)
    {
        builder.ToTable("card_event_groups");

        builder.HasKey(x => new { x.CardId, x.EventGroupId });

        builder.Property(x => x.CardId).HasColumnName("card_id");
        builder.Property(x => x.EventGroupId).HasColumnName("event_group_id");

        builder.HasOne(x => x.Card)
            .WithMany(x => x.EventGroupLinks)
            .HasForeignKey(x => x.CardId)
            .OnDelete(DeleteBehavior.Cascade);

        builder.HasOne(x => x.EventGroup)
            .WithMany(x => x.CardLinks)
            .HasForeignKey(x => x.EventGroupId)
            .OnDelete(DeleteBehavior.Cascade);
    }
}
