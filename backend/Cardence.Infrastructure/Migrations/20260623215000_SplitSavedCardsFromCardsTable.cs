using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Cardence.Infrastructure.Migrations
{
    /// <inheritdoc />
    public partial class SplitSavedCardsFromCardsTable : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "saved_cards",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    user_id = table.Column<Guid>(type: "uuid", nullable: false),
                    card_id = table.Column<string>(type: "character varying(6)", maxLength: 6, nullable: false),
                    creation_method = table.Column<string>(type: "character varying(32)", maxLength: 32, nullable: false),
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
                    saved_at = table.Column<long>(type: "bigint", nullable: false),
                    sort_order = table.Column<int>(type: "integer", nullable: false),
                    created_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    updated_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: false)
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

            migrationBuilder.Sql("""
                INSERT INTO saved_cards (
                    "Id", user_id, card_id, creation_method,
                    display_name, email, phone, company, title, website, linkedin,
                    skills, school, about, address, city, country, department, attended_events,
                    twitter, instagram, birthday, note, photo_url, accent_color, background_color,
                    saved_at, sort_order, created_at, updated_at
                )
                SELECT
                    c."Id", c.user_id, c.card_id, c.creation_method,
                    c.display_name, c.email, c.phone, c.company, c.title, c.website, c.linkedin,
                    c.skills, c.school, c.about, c.address, c.city, c.country, c.department, c.attended_events,
                    c.twitter, c.instagram, c.birthday, c.note, c.photo_url, c.accent_color, c.background_color,
                    COALESCE(c.saved_at, 0), c.sort_order, c.created_at, c.updated_at
                FROM cards c
                WHERE c.card_role = 'wallet';
                """);

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

            migrationBuilder.Sql("""
                INSERT INTO saved_card_event_groups (saved_card_id, event_group_id)
                SELECT ceg.card_id, ceg.event_group_id
                FROM card_event_groups ceg
                INNER JOIN cards c ON c."Id" = ceg.card_id
                WHERE c.card_role = 'wallet';
                """);

            migrationBuilder.DropTable(
                name: "card_event_groups");

            migrationBuilder.Sql("""
                DELETE FROM cards WHERE card_role = 'wallet';
                """);

            migrationBuilder.DropForeignKey(
                name: "FK_cards_cards_source_card_id",
                table: "cards");

            migrationBuilder.DropIndex(
                name: "IX_cards_card_id",
                table: "cards");

            migrationBuilder.DropIndex(
                name: "IX_cards_source_card_id",
                table: "cards");

            migrationBuilder.DropIndex(
                name: "IX_cards_user_id_card_id",
                table: "cards");

            migrationBuilder.DropIndex(
                name: "IX_cards_user_id_card_role",
                table: "cards");

            migrationBuilder.DropIndex(
                name: "IX_cards_user_id_sort_order",
                table: "cards");

            migrationBuilder.DropColumn(
                name: "card_role",
                table: "cards");

            migrationBuilder.DropColumn(
                name: "creation_method",
                table: "cards");

            migrationBuilder.DropColumn(
                name: "note",
                table: "cards");

            migrationBuilder.DropColumn(
                name: "saved_at",
                table: "cards");

            migrationBuilder.DropColumn(
                name: "sort_order",
                table: "cards");

            migrationBuilder.DropColumn(
                name: "source_card_id",
                table: "cards");

            migrationBuilder.CreateIndex(
                name: "IX_cards_card_id",
                table: "cards",
                column: "card_id",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_cards_user_id_card_id",
                table: "cards",
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

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "saved_card_event_groups");

            migrationBuilder.DropTable(
                name: "saved_cards");

            migrationBuilder.DropIndex(
                name: "IX_cards_card_id",
                table: "cards");

            migrationBuilder.DropIndex(
                name: "IX_cards_user_id_card_id",
                table: "cards");

            migrationBuilder.AddColumn<string>(
                name: "card_role",
                table: "cards",
                type: "character varying(16)",
                maxLength: 16,
                nullable: false,
                defaultValue: "own");

            migrationBuilder.AddColumn<string>(
                name: "creation_method",
                table: "cards",
                type: "character varying(32)",
                maxLength: 32,
                nullable: false,
                defaultValue: "own_card");

            migrationBuilder.AddColumn<string>(
                name: "note",
                table: "cards",
                type: "text",
                nullable: true);

            migrationBuilder.AddColumn<long>(
                name: "saved_at",
                table: "cards",
                type: "bigint",
                nullable: true);

            migrationBuilder.AddColumn<int>(
                name: "sort_order",
                table: "cards",
                type: "integer",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.AddColumn<Guid>(
                name: "source_card_id",
                table: "cards",
                type: "uuid",
                nullable: true);

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

            migrationBuilder.CreateIndex(
                name: "IX_card_event_groups_event_group_id",
                table: "card_event_groups",
                column: "event_group_id");

            migrationBuilder.AddForeignKey(
                name: "FK_cards_cards_source_card_id",
                table: "cards",
                column: "source_card_id",
                principalTable: "cards",
                principalColumn: "Id",
                onDelete: ReferentialAction.SetNull);
        }
    }
}
