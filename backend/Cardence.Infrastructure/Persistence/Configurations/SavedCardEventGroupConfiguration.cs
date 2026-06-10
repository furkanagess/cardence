using Cardence.Domain.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace Cardence.Infrastructure.Persistence.Configurations;

public sealed class SavedCardEventGroupConfiguration : IEntityTypeConfiguration<SavedCardEventGroup>
{
    public void Configure(EntityTypeBuilder<SavedCardEventGroup> builder)
    {
        builder.ToTable("saved_card_event_groups");

        builder.HasKey(x => new { x.SavedCardId, x.EventGroupId });

        builder.Property(x => x.SavedCardId).HasColumnName("saved_card_id");
        builder.Property(x => x.EventGroupId).HasColumnName("event_group_id");

        builder.HasOne(x => x.SavedCard)
            .WithMany(x => x.EventGroupLinks)
            .HasForeignKey(x => x.SavedCardId)
            .OnDelete(DeleteBehavior.Cascade);

        builder.HasOne(x => x.EventGroup)
            .WithMany(x => x.CardLinks)
            .HasForeignKey(x => x.EventGroupId)
            .OnDelete(DeleteBehavior.Cascade);
    }
}
