using System.Text.Json;
using Cardence.Domain.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.ChangeTracking;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace Cardence.Infrastructure.Persistence.Configurations;

public sealed class UserConfiguration : IEntityTypeConfiguration<User>
{
    private static readonly JsonSerializerOptions JsonOptions = new();

    private static readonly ValueComparer<List<string>> SavedCardIdsComparer =
        new(
            (left, right) =>
                (left ?? new List<string>()).SequenceEqual(
                    right ?? new List<string>(),
                    StringComparer.Ordinal),
            list => list.Aggregate(
                0,
                (hash, item) => HashCode.Combine(hash, item.GetHashCode(StringComparison.Ordinal))),
            list => list.ToList());

    private static readonly ValueComparer<Dictionary<string, string>> SavedCardNotesComparer =
        new(
            (left, right) => DictionaryEquals(left, right),
            dict => dict.Aggregate(
                0,
                (hash, pair) => HashCode.Combine(
                    hash,
                    pair.Key.GetHashCode(StringComparison.Ordinal),
                    pair.Value.GetHashCode(StringComparison.Ordinal))),
            dict => new Dictionary<string, string>(dict, StringComparer.Ordinal));

    public void Configure(EntityTypeBuilder<User> builder)
    {
        builder.ToTable("users");

        builder.HasKey(x => x.Id);

        builder.Property(x => x.DisplayName).HasMaxLength(200).HasColumnName("display_name");
        builder.Property(x => x.Email).HasMaxLength(320).HasColumnName("email");
        builder.Property(x => x.Phone).HasMaxLength(20).HasColumnName("phone");
        builder.Property(x => x.PhotoUrl).HasMaxLength(2048).HasColumnName("photo_url");
        builder.Property(x => x.PasswordHash).HasMaxLength(512).HasColumnName("password_hash");
        builder.Property(x => x.OnboardingCompleted).HasColumnName("onboarding_completed");
        builder.Property(x => x.CreatedAt).HasColumnName("created_at");
        builder.Property(x => x.UpdatedAt).HasColumnName("updated_at");

        builder.Property(x => x.SavedCardIds)
            .HasColumnName("saved_card_ids")
            .HasColumnType("jsonb")
            .HasConversion(
                v => JsonSerializer.Serialize(v ?? new List<string>(), JsonOptions),
                v => DeserializeIds(v))
            .Metadata.SetValueComparer(SavedCardIdsComparer);

        builder.Property(x => x.SavedCardNotes)
            .HasColumnName("saved_card_notes")
            .HasColumnType("jsonb")
            .HasConversion(
                v => JsonSerializer.Serialize(
                    v ?? new Dictionary<string, string>(),
                    JsonOptions),
                v => DeserializeNotes(v))
            .Metadata.SetValueComparer(SavedCardNotesComparer);

        builder.HasIndex(x => x.Email)
            .IsUnique()
            .HasDatabaseName("ix_users_email");

        builder.HasIndex(x => x.Phone)
            .IsUnique()
            .HasDatabaseName("ix_users_phone")
            .HasFilter("phone IS NOT NULL AND phone <> ''");
    }

    private static List<string> DeserializeIds(string? json)
    {
        if (string.IsNullOrWhiteSpace(json))
        {
            return [];
        }

        return JsonSerializer.Deserialize<List<string>>(json, JsonOptions) ?? [];
    }

    private static Dictionary<string, string> DeserializeNotes(string? json)
    {
        if (string.IsNullOrWhiteSpace(json))
        {
            return new Dictionary<string, string>(StringComparer.Ordinal);
        }

        var parsed = JsonSerializer.Deserialize<Dictionary<string, string>>(json, JsonOptions);
        return parsed is null
            ? new Dictionary<string, string>(StringComparer.Ordinal)
            : new Dictionary<string, string>(parsed, StringComparer.Ordinal);
    }

    private static bool DictionaryEquals(
        Dictionary<string, string>? left,
        Dictionary<string, string>? right)
    {
        if (ReferenceEquals(left, right))
        {
            return true;
        }

        if (left is null || right is null || left.Count != right.Count)
        {
            return false;
        }

        foreach (var (key, value) in left)
        {
            if (!right.TryGetValue(key, out var other) || other != value)
            {
                return false;
            }
        }

        return true;
    }
}
