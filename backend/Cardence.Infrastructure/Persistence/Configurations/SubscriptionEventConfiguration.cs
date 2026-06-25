using Cardence.Domain.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace Cardence.Infrastructure.Persistence.Configurations;

public sealed class SubscriptionEventConfiguration : IEntityTypeConfiguration<SubscriptionEvent>
{
    public void Configure(EntityTypeBuilder<SubscriptionEvent> builder)
    {
        builder.ToTable("subscription_events");

        builder.HasKey(x => x.Id);

        builder.Property(x => x.Provider).HasMaxLength(40).HasColumnName("provider");
        builder.Property(x => x.ProviderEventId)
            .HasMaxLength(200)
            .HasColumnName("provider_event_id");
        builder.Property(x => x.UserId).HasColumnName("user_id");
        builder.Property(x => x.EventType).HasMaxLength(80).HasColumnName("event_type");
        builder.Property(x => x.PayloadJson).HasColumnName("payload_json");
        builder.Property(x => x.ProcessedAt).HasColumnName("processed_at");

        builder.HasIndex(x => new { x.Provider, x.ProviderEventId }).IsUnique();
        builder.HasIndex(x => x.UserId);

        builder.HasOne(x => x.User)
            .WithMany()
            .HasForeignKey(x => x.UserId)
            .OnDelete(DeleteBehavior.Cascade);
    }
}
