using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Cardence.Infrastructure.Migrations;

/// <summary>
/// Read-only compatibility view so Railway/monitoring SQL that still
/// references <c>saved_cards</c> keeps working after the table was dropped.
/// Source of truth remains <c>users.saved_card_ids</c> + <c>cards</c>.
/// </summary>
public partial class AddSavedCardsCompatView : Migration
{
    /// <inheritdoc />
    protected override void Up(MigrationBuilder migrationBuilder)
    {
        migrationBuilder.Sql(
            """
            CREATE OR REPLACE VIEW public.saved_cards AS
            SELECT
                md5(u."Id"::text || ':' || ids.card_id)::uuid AS "Id",
                u."Id" AS user_id,
                ids.card_id,
                c.display_name,
                c.email,
                c.phone,
                c.company,
                c.title,
                c.website,
                c.linkedin,
                c.skills,
                c.school,
                c.about,
                c.address,
                c.city,
                c.country,
                c.department,
                c.attended_events,
                c.twitter,
                c.instagram,
                c.birthday,
                c.photo_url,
                c.accent_color,
                c.background_color,
                COALESCE(u.saved_card_notes ->> ids.card_id, NULL) AS note,
                'cardence'::character varying(32) AS creation_method,
                COALESCE(c.is_owner_premium, false) AS is_owner_premium,
                (ids.ord - 1)::integer AS sort_order,
                COALESCE(
                    (EXTRACT(EPOCH FROM COALESCE(c.created_at, u.created_at)) * 1000)::bigint,
                    0
                ) AS saved_at,
                COALESCE(c.created_at, u.created_at) AS created_at,
                COALESCE(c.updated_at, u.updated_at) AS updated_at
            FROM users u
            CROSS JOIN LATERAL jsonb_array_elements_text(
                COALESCE(u.saved_card_ids, '[]'::jsonb)
            ) WITH ORDINALITY AS ids(card_id, ord)
            LEFT JOIN cards c ON c.card_id = ids.card_id;
            """);
    }

    /// <inheritdoc />
    protected override void Down(MigrationBuilder migrationBuilder)
    {
        migrationBuilder.Sql("DROP VIEW IF EXISTS public.saved_cards;");
    }
}
