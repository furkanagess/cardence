using Cardence.Domain.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace Cardence.Infrastructure.Persistence.Configurations;

public sealed class CardInteractionConfiguration : IEntityTypeConfiguration<CardInteraction>
{
    public void Configure(EntityTypeBuilder<CardInteraction> builder)
    {
        builder.ToTable("card_interactions");

        builder.HasKey(x => x.Id);

        builder.Property(x => x.ActorUserId).HasColumnName("actor_user_id");
        builder.Property(x => x.TargetCardEntityId).HasColumnName("target_card_entity_id");
        builder.Property(x => x.TargetCardPublicId)
            .HasMaxLength(20)
            .HasColumnName("target_card_public_id");
        builder.Property(x => x.EventType).HasMaxLength(40).HasColumnName("event_type");
        builder.Property(x => x.Source).HasMaxLength(40).HasColumnName("source");
        builder.Property(x => x.OrganizationEventId).HasColumnName("organization_event_id");
        builder.Property(x => x.OccurredAt).HasColumnName("occurred_at");

        builder.HasIndex(x => x.TargetCardPublicId);
        builder.HasIndex(x => x.TargetCardEntityId);
        builder.HasIndex(x => new { x.TargetCardPublicId, x.EventType });
        builder.HasIndex(x => x.OccurredAt);

        builder.HasOne(x => x.ActorUser)
            .WithMany()
            .HasForeignKey(x => x.ActorUserId)
            .OnDelete(DeleteBehavior.SetNull);

        builder.HasOne(x => x.TargetCard)
            .WithMany()
            .HasForeignKey(x => x.TargetCardEntityId)
            .OnDelete(DeleteBehavior.Cascade);
    }
}
