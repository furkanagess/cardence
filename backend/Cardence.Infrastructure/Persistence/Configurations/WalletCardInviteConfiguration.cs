using Cardence.Domain.Constants;
using Cardence.Domain.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace Cardence.Infrastructure.Persistence.Configurations;

public sealed class WalletCardInviteConfiguration
    : IEntityTypeConfiguration<WalletCardInvite>
{
    public void Configure(EntityTypeBuilder<WalletCardInvite> builder)
    {
        builder.ToTable("wallet_card_invites");

        builder.HasKey(x => x.Id);

        builder.Property(x => x.Id).HasColumnName("id");
        builder.Property(x => x.InviterUserId).HasColumnName("inviter_user_id");
        builder.Property(x => x.InviteeUserId).HasColumnName("invitee_user_id");
        builder.Property(x => x.ProposedCardEntityId).HasColumnName("proposed_card_entity_id");
        builder.Property(x => x.ProposedCardId)
            .HasColumnName("proposed_card_id")
            .HasMaxLength(BusinessCardConstants.CardIdLength)
            .IsRequired();
        builder.Property(x => x.SavedCardId)
            .HasColumnName("saved_card_id")
            .HasMaxLength(BusinessCardConstants.CardIdLength)
            .IsRequired();
        builder.Property(x => x.Status)
            .HasColumnName("status")
            .HasMaxLength(20)
            .IsRequired();
        builder.Property(x => x.CreatedAtUtc).HasColumnName("created_at_utc");
        builder.Property(x => x.ExpiresAtUtc).HasColumnName("expires_at_utc");
        builder.Property(x => x.RespondedAtUtc).HasColumnName("responded_at_utc");

        builder.HasIndex(x => new { x.InviteeUserId, x.Status });
        builder.HasIndex(x => new { x.InviteeUserId, x.InviterUserId, x.Status });
        builder.HasIndex(x => x.ExpiresAtUtc);

        builder.HasOne(x => x.InviterUser)
            .WithMany()
            .HasForeignKey(x => x.InviterUserId)
            .OnDelete(DeleteBehavior.Cascade);

        builder.HasOne(x => x.InviteeUser)
            .WithMany()
            .HasForeignKey(x => x.InviteeUserId)
            .OnDelete(DeleteBehavior.Cascade);

        builder.HasOne(x => x.ProposedCard)
            .WithMany()
            .HasForeignKey(x => x.ProposedCardEntityId)
            .OnDelete(DeleteBehavior.Cascade);
    }
}
