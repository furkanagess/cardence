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
        builder.Property(x => x.CreatedAt).HasColumnName("created_at");

        builder.HasIndex(x => x.UserId);
        builder.HasIndex(x => new { x.UserId, x.Name })
            .IsUnique()
            .HasDatabaseName("ux_event_groups_user_name");

        builder.HasOne(x => x.User)
            .WithMany()
            .HasForeignKey(x => x.UserId)
            .OnDelete(DeleteBehavior.Cascade);
    }
}
