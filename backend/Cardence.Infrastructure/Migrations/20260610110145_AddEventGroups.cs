using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Cardence.Infrastructure.Migrations
{
    /// <inheritdoc />
    public partial class AddEventGroups : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "linked_event_group_ids",
                table: "saved_cards");

            migrationBuilder.CreateTable(
                name: "event_groups",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    user_id = table.Column<Guid>(type: "uuid", nullable: false),
                    name = table.Column<string>(type: "character varying(200)", maxLength: 200, nullable: false),
                    created_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_event_groups", x => x.Id);
                    table.ForeignKey(
                        name: "FK_event_groups_users_user_id",
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
                name: "IX_event_groups_user_id",
                table: "event_groups",
                column: "user_id");

            migrationBuilder.CreateIndex(
                name: "ux_event_groups_user_name",
                table: "event_groups",
                columns: new[] { "user_id", "name" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_saved_card_event_groups_event_group_id",
                table: "saved_card_event_groups",
                column: "event_group_id");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "saved_card_event_groups");

            migrationBuilder.DropTable(
                name: "event_groups");

            migrationBuilder.AddColumn<string>(
                name: "linked_event_group_ids",
                table: "saved_cards",
                type: "jsonb",
                nullable: false,
                defaultValue: "");
        }
    }
}
