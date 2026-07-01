using Cardence.Domain.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace Cardence.Infrastructure.Persistence.Configurations;

public sealed class EventGroupCardInviteConfiguration
    : IEntityTypeConfiguration<EventGroupCardInvite>
{
    public void Configure(EntityTypeBuilder<EventGroupCardInvite> builder)
    {
        builder.ToTable("event_group_card_invites");

        builder.HasKey(x => x.Id);

        builder.Property(x => x.Id).HasColumnName("id");
        builder.Property(x => x.EventGroupId).HasColumnName("event_group_id");
        builder.Property(x => x.InviterUserId).HasColumnName("inviter_user_id");
        builder.Property(x => x.InviteeUserId).HasColumnName("invitee_user_id");
        builder.Property(x => x.CardEntityId).HasColumnName("card_entity_id");
        builder.Property(x => x.CardId)
            .HasColumnName("card_id")
            .HasMaxLength(64)
            .IsRequired();
        builder.Property(x => x.Status)
            .HasColumnName("status")
            .HasMaxLength(20)
            .IsRequired();
        builder.Property(x => x.CreatedAtUtc).HasColumnName("created_at_utc");
        builder.Property(x => x.RespondedAtUtc).HasColumnName("responded_at_utc");

        builder.HasIndex(x => new { x.InviteeUserId, x.Status });
        builder.HasIndex(x => new { x.EventGroupId, x.CardEntityId, x.Status });

        builder.HasOne(x => x.EventGroup)
            .WithMany(x => x.CardInvites)
            .HasForeignKey(x => x.EventGroupId)
            .OnDelete(DeleteBehavior.Cascade);

        builder.HasOne(x => x.InviterUser)
            .WithMany()
            .HasForeignKey(x => x.InviterUserId)
            .OnDelete(DeleteBehavior.Cascade);

        builder.HasOne(x => x.InviteeUser)
            .WithMany()
            .HasForeignKey(x => x.InviteeUserId)
            .OnDelete(DeleteBehavior.Cascade);

        builder.HasOne(x => x.Card)
            .WithMany()
            .HasForeignKey(x => x.CardEntityId)
            .OnDelete(DeleteBehavior.Cascade);
    }
}
