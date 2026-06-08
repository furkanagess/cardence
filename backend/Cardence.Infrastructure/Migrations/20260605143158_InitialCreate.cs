using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Cardence.Infrastructure.Migrations
{
    /// <inheritdoc />
    public partial class InitialCreate : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "users",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    display_name = table.Column<string>(type: "character varying(200)", maxLength: 200, nullable: true),
                    email = table.Column<string>(type: "character varying(320)", maxLength: 320, nullable: true),
                    phone = table.Column<string>(type: "character varying(20)", maxLength: 20, nullable: true),
                    onboarding_completed = table.Column<bool>(type: "boolean", nullable: false),
                    created_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    updated_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_users", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "business_cards",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    user_id = table.Column<Guid>(type: "uuid", nullable: false),
                    card_id = table.Column<string>(type: "character varying(36)", maxLength: 36, nullable: false),
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
                    accent_color = table.Column<string>(type: "character varying(7)", maxLength: 7, nullable: true),
                    background_color = table.Column<string>(type: "character varying(7)", maxLength: 7, nullable: true),
                    last_used_palette_background_color = table.Column<string>(type: "character varying(7)", maxLength: 7, nullable: true),
                    created_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    updated_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: false)
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
                name: "IX_users_email",
                table: "users",
                column: "email",
                unique: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "business_cards");

            migrationBuilder.DropTable(
                name: "users");
        }
    }
}
