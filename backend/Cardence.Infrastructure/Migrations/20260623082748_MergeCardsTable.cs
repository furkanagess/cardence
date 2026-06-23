using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Cardence.Infrastructure.Migrations
{
    /// <inheritdoc />
    public partial class MergeCardsTable : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "cards",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    user_id = table.Column<Guid>(type: "uuid", nullable: false),
                    card_id = table.Column<string>(type: "character varying(6)", maxLength: 6, nullable: false),
                    card_role = table.Column<string>(type: "character varying(16)", maxLength: 16, nullable: false),
                    creation_method = table.Column<string>(type: "character varying(32)", maxLength: 32, nullable: false),
                    source_card_id = table.Column<Guid>(type: "uuid", nullable: true),
                    card_name = table.Column<string>(type: "character varying(200)", maxLength: 200, nullable: true),
                    display_name = table.Column<string>(type: "character varying(200)", maxLength: 200, nullable: true),
                    email = table.Column<string>(type: "character varying(320)", maxLength: 320, nullable: true),
                    phone = table.Column<string>(type: "character varying(20)", maxLength: 20, nullable: true),
                    company = table.Column<string>(type: "character varying(200)", maxLength: 200, nullable: true),
                    title = table.Column<string>(type: "character varying(200)", maxLength: 200, nullable: true),
                    website = table.Column<string>(type: "character varying(500)", maxLength: 500, nullable: true),
                    linkedin = table.Column<string>(type: "character varying(500)", maxLength: 500, nullable: true),
                    skills = table.Column<string>(type: "text", nullable: true),
                    school = table.Column<string>(type: "character varying(200)", maxLength: 200, nullable: true),
                    about = table.Column<string>(type: "text", nullable: true),
                    address = table.Column<string>(type: "character varying(500)", maxLength: 500, nullable: true),
                    city = table.Column<string>(type: "character varying(120)", maxLength: 120, nullable: true),
                    country = table.Column<string>(type: "character varying(120)", maxLength: 120, nullable: true),
                    department = table.Column<string>(type: "character varying(200)", maxLength: 200, nullable: true),
                    attended_events = table.Column<string>(type: "text", nullable: true),
                    twitter = table.Column<string>(type: "character varying(500)", maxLength: 500, nullable: true),
                    instagram = table.Column<string>(type: "character varying(500)", maxLength: 500, nullable: true),
                    birthday = table.Column<string>(type: "character varying(50)", maxLength: 50, nullable: true),
                    note = table.Column<string>(type: "text", nullable: true),
                    photo_url = table.Column<string>(type: "character varying(2048)", maxLength: 2048, nullable: true),
                    accent_color = table.Column<string>(type: "character varying(7)", maxLength: 7, nullable: true),
                    background_color = table.Column<string>(type: "character varying(7)", maxLength: 7, nullable: true),
                    last_used_palette_background_color = table.Column<string>(type: "character varying(7)", maxLength: 7, nullable: true),
                    saved_at = table.Column<long>(type: "bigint", nullable: true),
                    sort_order = table.Column<int>(type: "integer", nullable: false),
                    save_count = table.Column<int>(type: "integer", nullable: false, defaultValue: 0),
                    created_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    updated_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_cards", x => x.Id);
                    table.ForeignKey(
                        name: "FK_cards_cards_source_card_id",
                        column: x => x.source_card_id,
                        principalTable: "cards",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.SetNull);
                    table.ForeignKey(
                        name: "FK_cards_users_user_id",
                        column: x => x.user_id,
                        principalTable: "users",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.Sql("""
                INSERT INTO cards (
                    "Id", user_id, card_id, card_role, creation_method, source_card_id,
                    card_name, display_name, email, phone, company, title, website, linkedin,
                    skills, school, about, address, city, country, department, attended_events,
                    twitter, instagram, birthday, note, photo_url, accent_color, background_color,
                    last_used_palette_background_color, saved_at, sort_order, save_count, created_at, updated_at
                )
                SELECT
                    bc."Id", bc.user_id, bc.card_id, 'own', 'own_card', NULL,
                    bc.card_name, bc.display_name, bc.email, bc.phone, bc.company, bc.title, bc.website, bc.linkedin,
                    bc.skills, bc.school, bc.about, bc.address, bc.city, bc.country, bc.department, bc.attended_events,
                    bc.twitter, bc.instagram, bc.birthday, NULL, bc.photo_url, bc.accent_color, bc.background_color,
                    bc.last_used_palette_background_color, NULL, 0, bc.save_count, bc.created_at, bc.updated_at
                FROM business_cards bc;
                """);

            migrationBuilder.Sql("""
                INSERT INTO cards (
                    "Id", user_id, card_id, card_role, creation_method, source_card_id,
                    card_name, display_name, email, phone, company, title, website, linkedin,
                    skills, school, about, address, city, country, department, attended_events,
                    twitter, instagram, birthday, note, photo_url, accent_color, background_color,
                    last_used_palette_background_color, saved_at, sort_order, save_count, created_at, updated_at
                )
                SELECT
                    sc."Id", sc.user_id, sc.card_id, 'wallet',
                    CASE
                        WHEN LOWER(sc.source_type) = 'manual' THEN 'manual'
                        ELSE 'cardence_link'
                    END,
                    NULL,
                    NULL, sc.display_name, sc.email, sc.phone, sc.company, sc.title, sc.website, sc.linkedin,
                    sc.skills, sc.school, sc.about, sc.address, sc.city, sc.country, sc.department, sc.attended_events,
                    sc.twitter, sc.instagram, sc.birthday, sc.note, sc.photo_url, sc.accent_color, sc.background_color,
                    NULL, sc.saved_at, sc.sort_order, 0,
                    COALESCE(to_timestamp(sc.saved_at / 1000.0) AT TIME ZONE 'UTC', NOW()),
                    COALESCE(to_timestamp(sc.saved_at / 1000.0) AT TIME ZONE 'UTC', NOW())
                FROM saved_cards sc;
                """);

            migrationBuilder.Sql("""
                UPDATE cards wallet
                SET source_card_id = own."Id"
                FROM cards own
                WHERE wallet.card_role = 'wallet'
                  AND own.card_role = 'own'
                  AND wallet.card_id = own.card_id;
                """);

            migrationBuilder.CreateTable(
                name: "card_event_groups",
                columns: table => new
                {
                    card_id = table.Column<Guid>(type: "uuid", nullable: false),
                    event_group_id = table.Column<Guid>(type: "uuid", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_card_event_groups", x => new { x.card_id, x.event_group_id });
                    table.ForeignKey(
                        name: "FK_card_event_groups_cards_card_id",
                        column: x => x.card_id,
                        principalTable: "cards",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_card_event_groups_event_groups_event_group_id",
                        column: x => x.event_group_id,
                        principalTable: "event_groups",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.Sql("""
                INSERT INTO card_event_groups (card_id, event_group_id)
                SELECT saved_card_id, event_group_id
                FROM saved_card_event_groups;
                """);

            migrationBuilder.DropTable(
                name: "saved_card_event_groups");

            migrationBuilder.DropTable(
                name: "saved_cards");

            migrationBuilder.DropTable(
                name: "business_cards");

            migrationBuilder.CreateIndex(
                name: "IX_card_event_groups_event_group_id",
                table: "card_event_groups",
                column: "event_group_id");

            migrationBuilder.CreateIndex(
                name: "IX_cards_card_id",
                table: "cards",
                column: "card_id",
                unique: true,
                filter: "card_role = 'own'");

            migrationBuilder.CreateIndex(
                name: "IX_cards_source_card_id",
                table: "cards",
                column: "source_card_id");

            migrationBuilder.CreateIndex(
                name: "IX_cards_user_id_card_id",
                table: "cards",
                columns: new[] { "user_id", "card_id" },
                unique: true,
                filter: "card_role = 'wallet'");

            migrationBuilder.CreateIndex(
                name: "IX_cards_user_id_card_role",
                table: "cards",
                columns: new[] { "user_id", "card_role" });

            migrationBuilder.CreateIndex(
                name: "IX_cards_user_id_sort_order",
                table: "cards",
                columns: new[] { "user_id", "sort_order" },
                filter: "card_role = 'wallet'");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "card_event_groups");

            migrationBuilder.DropTable(
                name: "cards");

            migrationBuilder.CreateTable(
                name: "business_cards",
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
                    card_name = table.Column<string>(type: "character varying(200)", maxLength: 200, nullable: true),
                    city = table.Column<string>(type: "character varying(120)", maxLength: 120, nullable: true),
                    company = table.Column<string>(type: "character varying(200)", maxLength: 200, nullable: true),
                    country = table.Column<string>(type: "character varying(120)", maxLength: 120, nullable: true),
                    created_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    department = table.Column<string>(type: "character varying(200)", maxLength: 200, nullable: true),
                    display_name = table.Column<string>(type: "character varying(200)", maxLength: 200, nullable: true),
                    email = table.Column<string>(type: "character varying(320)", maxLength: 320, nullable: true),
                    instagram = table.Column<string>(type: "character varying(500)", maxLength: 500, nullable: true),
                    last_used_palette_background_color = table.Column<string>(type: "character varying(7)", maxLength: 7, nullable: true),
                    linkedin = table.Column<string>(type: "character varying(500)", maxLength: 500, nullable: true),
                    phone = table.Column<string>(type: "character varying(20)", maxLength: 20, nullable: true),
                    photo_url = table.Column<string>(type: "character varying(2048)", maxLength: 2048, nullable: true),
                    save_count = table.Column<int>(type: "integer", nullable: false, defaultValue: 0),
                    school = table.Column<string>(type: "character varying(200)", maxLength: 200, nullable: true),
                    skills = table.Column<string>(type: "text", nullable: true),
                    title = table.Column<string>(type: "character varying(200)", maxLength: 200, nullable: true),
                    twitter = table.Column<string>(type: "character varying(500)", maxLength: 500, nullable: true),
                    updated_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    website = table.Column<string>(type: "character varying(500)", maxLength: 500, nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_business_cards", x => x.Id);
                    table.ForeignKey(
                        name: "FK_business_cards_users_user_id",
                        column: x => x.user_id,
                        principalTable: "users",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

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
                    department = table.Column<string>(type: "character varying(200)", maxLength: 200, nullable: true),
                    display_name = table.Column<string>(type: "character varying(200)", maxLength: 200, nullable: true),
                    email = table.Column<string>(type: "character varying(320)", maxLength: 320, nullable: true),
                    instagram = table.Column<string>(type: "character varying(500)", maxLength: 500, nullable: true),
                    linkedin = table.Column<string>(type: "character varying(500)", maxLength: 500, nullable: true),
                    note = table.Column<string>(type: "text", nullable: true),
                    phone = table.Column<string>(type: "character varying(20)", maxLength: 20, nullable: true),
                    photo_url = table.Column<string>(type: "character varying(500)", maxLength: 500, nullable: true),
                    saved_at = table.Column<long>(type: "bigint", nullable: false),
                    school = table.Column<string>(type: "character varying(200)", maxLength: 200, nullable: true),
                    skills = table.Column<string>(type: "text", nullable: true),
                    sort_order = table.Column<int>(type: "integer", nullable: false),
                    source_type = table.Column<string>(type: "character varying(16)", maxLength: 16, nullable: false, defaultValue: "cardence"),
                    title = table.Column<string>(type: "character varying(200)", maxLength: 200, nullable: true),
                    twitter = table.Column<string>(type: "character varying(500)", maxLength: 500, nullable: true),
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
                name: "IX_business_cards_card_id",
                table: "business_cards",
                column: "card_id",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_business_cards_user_id_card_id",
                table: "business_cards",
                columns: new[] { "user_id", "card_id" });

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
                name: "IX_saved_cards_user_id_sort_order",
                table: "saved_cards",
                columns: new[] { "user_id", "sort_order" });
        }
    }
}
