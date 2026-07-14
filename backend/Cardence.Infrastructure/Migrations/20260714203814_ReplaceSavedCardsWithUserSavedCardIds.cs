using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Cardence.Infrastructure.Migrations;

/// <inheritdoc />
public partial class ReplaceSavedCardsWithUserSavedCardIds : Migration
{
    /// <inheritdoc />
    protected override void Up(MigrationBuilder migrationBuilder)
    {
        migrationBuilder.AddColumn<bool>(
            name: "is_wallet_contact",
            table: "cards",
            type: "boolean",
            nullable: false,
            defaultValue: false);

        migrationBuilder.AddColumn<string>(
            name: "saved_card_ids",
            table: "users",
            type: "jsonb",
            nullable: false,
            defaultValueSql: "'[]'::jsonb");

        migrationBuilder.AddColumn<string>(
            name: "saved_card_notes",
            table: "users",
            type: "jsonb",
            nullable: false,
            defaultValueSql: "'{}'::jsonb");

        migrationBuilder.CreateTable(
            name: "event_group_wallet_cards",
            columns: table => new
            {
                user_id = table.Column<Guid>(type: "uuid", nullable: false),
                card_id = table.Column<string>(type: "character varying(6)", maxLength: 6, nullable: false),
                event_group_id = table.Column<Guid>(type: "uuid", nullable: false)
            },
            constraints: table =>
            {
                table.PrimaryKey("PK_event_group_wallet_cards", x => new { x.user_id, x.card_id, x.event_group_id });
                table.ForeignKey(
                    name: "FK_event_group_wallet_cards_event_groups_event_group_id",
                    column: x => x.event_group_id,
                    principalTable: "event_groups",
                    principalColumn: "Id",
                    onDelete: ReferentialAction.Cascade);
                table.ForeignKey(
                    name: "FK_event_group_wallet_cards_users_user_id",
                    column: x => x.user_id,
                    principalTable: "users",
                    principalColumn: "Id",
                    onDelete: ReferentialAction.Cascade);
            });

        migrationBuilder.CreateIndex(
            name: "IX_cards_user_id_is_wallet_contact",
            table: "cards",
            columns: new[] { "user_id", "is_wallet_contact" });

        migrationBuilder.CreateIndex(
            name: "IX_event_group_wallet_cards_event_group_id",
            table: "event_group_wallet_cards",
            column: "event_group_id");

        migrationBuilder.CreateIndex(
            name: "IX_event_group_wallet_cards_user_id_card_id",
            table: "event_group_wallet_cards",
            columns: new[] { "user_id", "card_id" });

        // Manuel kayıtlardan cards satırı oluştur (Cardence kartı yoksa).
        migrationBuilder.Sql(
            """
            INSERT INTO cards (
                "Id", user_id, card_id, display_name, email, phone, company, title, website, linkedin,
                skills, school, about, address, city, country, department, attended_events, twitter, instagram,
                birthday, photo_url, accent_color, background_color, save_count, is_owner_premium, is_wallet_contact,
                created_at, updated_at)
            SELECT
                gen_random_uuid(),
                sc.user_id,
                sc.card_id,
                sc.display_name,
                sc.email,
                sc.phone,
                sc.company,
                sc.title,
                sc.website,
                sc.linkedin,
                sc.skills,
                sc.school,
                sc.about,
                sc.address,
                sc.city,
                sc.country,
                sc.department,
                sc.attended_events,
                sc.twitter,
                sc.instagram,
                sc.birthday,
                sc.photo_url,
                sc.accent_color,
                sc.background_color,
                0,
                false,
                true,
                sc.created_at,
                sc.updated_at
            FROM saved_cards sc
            WHERE NOT EXISTS (
                SELECT 1 FROM cards c WHERE c.card_id = sc.card_id
            );
            """);

        // users.saved_card_ids: kullanıcı bazında tekilleştirilmiş sıralı liste.
        migrationBuilder.Sql(
            """
            UPDATE users u
            SET saved_card_ids = COALESCE((
                SELECT jsonb_agg(card_id ORDER BY sort_order, saved_at)
                FROM (
                    SELECT DISTINCT ON (sc.card_id)
                        sc.card_id,
                        sc.sort_order,
                        sc.saved_at
                    FROM saved_cards sc
                    WHERE sc.user_id = u."Id"
                    ORDER BY sc.card_id, sc.sort_order, sc.saved_at
                ) d
            ), '[]'::jsonb);
            """);

        // users.saved_card_notes
        migrationBuilder.Sql(
            """
            UPDATE users u
            SET saved_card_notes = COALESCE((
                SELECT jsonb_object_agg(sc.card_id, sc.note)
                FROM saved_cards sc
                WHERE sc.user_id = u."Id"
                  AND sc.note IS NOT NULL
                  AND btrim(sc.note) <> ''
            ), '{}'::jsonb);
            """);

        // Etkinlik bağlantılarını yeni tabloya taşı.
        migrationBuilder.Sql(
            """
            INSERT INTO event_group_wallet_cards (user_id, card_id, event_group_id)
            SELECT DISTINCT sc.user_id, sc.card_id, link.event_group_id
            FROM saved_card_event_groups link
            INNER JOIN saved_cards sc ON sc."Id" = link.saved_card_id
            ON CONFLICT DO NOTHING;
            """);

        migrationBuilder.DropTable(name: "saved_card_event_groups");
        migrationBuilder.DropTable(name: "saved_cards");
    }

    /// <inheritdoc />
    protected override void Down(MigrationBuilder migrationBuilder)
    {
        migrationBuilder.DropTable(name: "event_group_wallet_cards");

        migrationBuilder.DropIndex(
            name: "IX_cards_user_id_is_wallet_contact",
            table: "cards");

        migrationBuilder.DropColumn(name: "saved_card_ids", table: "users");
        migrationBuilder.DropColumn(name: "saved_card_notes", table: "users");
        migrationBuilder.DropColumn(name: "is_wallet_contact", table: "cards");

        migrationBuilder.CreateTable(
            name: "saved_cards",
            columns: table => new
            {
                Id = table.Column<Guid>(type: "uuid", nullable: false),
                user_id = table.Column<Guid>(type: "uuid", nullable: false),
                about = table.Column<string>(type: "text", nullable: true),
                accent_color = table.Column<string>(type: "character varying(7)", maxLength: 7, nullable: true),
                address = table.Column<string>(type: "character varying(500)", maxLength: 500, nullable: true),
                attended_events = table.Column<string>(type: "text", nullable: true),
                background_color = table.Column<string>(type: "character varying(7)", maxLength: 7, nullable: true),
                birthday = table.Column<string>(type: "character varying(50)", maxLength: 50, nullable: true),
                card_id = table.Column<string>(type: "character varying(6)", maxLength: 6, nullable: false),
                city = table.Column<string>(type: "character varying(120)", maxLength: 120, nullable: true),
                company = table.Column<string>(type: "character varying(200)", maxLength: 200, nullable: true),
                country = table.Column<string>(type: "character varying(120)", maxLength: 120, nullable: true),
                created_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                creation_method = table.Column<string>(type: "character varying(32)", maxLength: 32, nullable: false),
                department = table.Column<string>(type: "character varying(200)", maxLength: 200, nullable: true),
                display_name = table.Column<string>(type: "character varying(200)", maxLength: 200, nullable: true),
                email = table.Column<string>(type: "character varying(320)", maxLength: 320, nullable: true),
                instagram = table.Column<string>(type: "character varying(500)", maxLength: 500, nullable: true),
                is_owner_premium = table.Column<bool>(type: "boolean", nullable: false, defaultValue: false),
                linkedin = table.Column<string>(type: "character varying(500)", maxLength: 500, nullable: true),
                note = table.Column<string>(type: "text", nullable: true),
                phone = table.Column<string>(type: "character varying(20)", maxLength: 20, nullable: true),
                photo_url = table.Column<string>(type: "character varying(2048)", maxLength: 2048, nullable: true),
                saved_at = table.Column<long>(type: "bigint", nullable: false),
                school = table.Column<string>(type: "character varying(200)", maxLength: 200, nullable: true),
                skills = table.Column<string>(type: "text", nullable: true),
                sort_order = table.Column<int>(type: "integer", nullable: false),
                title = table.Column<string>(type: "character varying(200)", maxLength: 200, nullable: true),
                twitter = table.Column<string>(type: "character varying(500)", maxLength: 500, nullable: true),
                updated_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                website = table.Column<string>(type: "character varying(500)", maxLength: 500, nullable: true)
            },
            constraints: table =>
            {
                table.PrimaryKey("PK_saved_cards", x => x.Id);
                table.ForeignKey(
                    name: "FK_saved_cards_users_user_id",
                    column: x => x.user_id,
                    principalTable: "users",
                    principalColumn: "Id",
                    onDelete: ReferentialAction.Cascade);
            });

        migrationBuilder.CreateTable(
            name: "saved_card_event_groups",
            columns: table => new
            {
                saved_card_id = table.Column<Guid>(type: "uuid", nullable: false),
                event_group_id = table.Column<Guid>(type: "uuid", nullable: false)
            },
            constraints: table =>
            {
                table.PrimaryKey("PK_saved_card_event_groups", x => new { x.saved_card_id, x.event_group_id });
                table.ForeignKey(
                    name: "FK_saved_card_event_groups_event_groups_event_group_id",
                    column: x => x.event_group_id,
                    principalTable: "event_groups",
                    principalColumn: "Id",
                    onDelete: ReferentialAction.Cascade);
                table.ForeignKey(
                    name: "FK_saved_card_event_groups_saved_cards_saved_card_id",
                    column: x => x.saved_card_id,
                    principalTable: "saved_cards",
                    principalColumn: "Id",
                    onDelete: ReferentialAction.Cascade);
            });

        migrationBuilder.CreateIndex(
            name: "IX_saved_card_event_groups_event_group_id",
            table: "saved_card_event_groups",
            column: "event_group_id");

        migrationBuilder.CreateIndex(
            name: "IX_saved_cards_user_id_card_id",
            table: "saved_cards",
            columns: new[] { "user_id", "card_id" },
            unique: true);

        migrationBuilder.CreateIndex(
            name: "IX_saved_cards_user_id_is_owner_premium",
            table: "saved_cards",
            columns: new[] { "user_id", "is_owner_premium" });

        migrationBuilder.CreateIndex(
            name: "IX_saved_cards_user_id_sort_order",
            table: "saved_cards",
            columns: new[] { "user_id", "sort_order" });
    }
}
