using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Cardence.Infrastructure.Migrations
{
    /// <inheritdoc />
    public partial class AddSavedCardsAndWallet : Migration
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
                    card_id = table.Column<string>(type: "character varying(36)", maxLength: 36, nullable: false),
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
                    saved_at = table.Column<long>(type: "bigint", nullable: false),
                    sort_order = table.Column<int>(type: "integer", nullable: false),
                    linked_event_group_ids = table.Column<string>(type: "jsonb", nullable: false)
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
                name: "wallet_entitlements",
                columns: table => new
                {
                    UserId = table.Column<Guid>(type: "uuid", nullable: false),
                    tier = table.Column<string>(type: "character varying(20)", maxLength: 20, nullable: false),
                    max_cards = table.Column<int>(type: "integer", nullable: false),
                    updated_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_wallet_entitlements", x => x.UserId);
                    table.ForeignKey(
                        name: "FK_wallet_entitlements_users_UserId",
                        column: x => x.UserId,
                        principalTable: "users",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

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
                name: "saved_cards");

            migrationBuilder.DropTable(
                name: "wallet_entitlements");
        }
    }
}
