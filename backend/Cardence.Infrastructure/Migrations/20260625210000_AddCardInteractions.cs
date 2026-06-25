using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Cardence.Infrastructure.Migrations
{
    /// <inheritdoc />
    public partial class AddCardInteractions : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "card_interactions",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    actor_user_id = table.Column<Guid>(type: "uuid", nullable: true),
                    target_card_entity_id = table.Column<Guid>(type: "uuid", nullable: false),
                    target_card_public_id = table.Column<string>(type: "character varying(20)", maxLength: 20, nullable: false),
                    event_type = table.Column<string>(type: "character varying(40)", maxLength: 40, nullable: false),
                    source = table.Column<string>(type: "character varying(40)", maxLength: 40, nullable: false),
                    organization_event_id = table.Column<Guid>(type: "uuid", nullable: true),
                    occurred_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_card_interactions", x => x.Id);
                    table.ForeignKey(
                        name: "FK_card_interactions_cards_target_card_entity_id",
                        column: x => x.target_card_entity_id,
                        principalTable: "cards",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_card_interactions_users_actor_user_id",
                        column: x => x.actor_user_id,
                        principalTable: "users",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.SetNull);
                });

            migrationBuilder.CreateIndex(
                name: "IX_card_interactions_actor_user_id",
                table: "card_interactions",
                column: "actor_user_id");

            migrationBuilder.CreateIndex(
                name: "IX_card_interactions_occurred_at",
                table: "card_interactions",
                column: "occurred_at");

            migrationBuilder.CreateIndex(
                name: "IX_card_interactions_target_card_entity_id",
                table: "card_interactions",
                column: "target_card_entity_id");

            migrationBuilder.CreateIndex(
                name: "IX_card_interactions_target_card_public_id",
                table: "card_interactions",
                column: "target_card_public_id");

            migrationBuilder.CreateIndex(
                name: "IX_card_interactions_target_card_public_id_event_type",
                table: "card_interactions",
                columns: new[] { "target_card_public_id", "event_type" });
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "card_interactions");
        }
    }
}
