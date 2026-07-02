using Cardence.Domain.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace Cardence.Infrastructure.Persistence.Configurations;

public sealed class EventGroupConfiguration : IEntityTypeConfiguration<EventGroup>
{
    public void Configure(EntityTypeBuilder<EventGroup> builder)
    {
        builder.ToTable("event_groups");

        builder.HasKey(x => x.Id);

        builder.Property(x => x.UserId).HasColumnName("user_id");
        builder.Property(x => x.Name).HasMaxLength(200).HasColumnName("name");
        builder.Property(x => x.Location).HasMaxLength(500).HasColumnName("location");
        builder.Property(x => x.Description).HasMaxLength(2000).HasColumnName("description");
        builder.Property(x => x.StartAtUtc).HasColumnName("start_at_utc");
        builder.Property(x => x.EndAtUtc).HasColumnName("end_at_utc");
        builder.Property(x => x.Timezone).HasMaxLength(80).HasColumnName("timezone");
        builder.Property(x => x.EventDate).HasColumnName("event_date");
        builder.Property(x => x.PhotoUrl).HasMaxLength(2048).HasColumnName("photo_url");
        builder.Property(x => x.CreatedAt).HasColumnName("created_at");

        builder.HasIndex(x => x.UserId);
        builder.HasIndex(x => new { x.UserId, x.StartAtUtc });
        builder.HasIndex(x => new { x.UserId, x.EndAtUtc });
        builder.HasIndex(x => new { x.UserId, x.Name })
            .IsUnique()
            .HasDatabaseName("ux_event_groups_user_name");

        builder.HasOne(x => x.User)
            .WithMany()
            .HasForeignKey(x => x.UserId)
            .OnDelete(DeleteBehavior.Cascade);
    }
}
