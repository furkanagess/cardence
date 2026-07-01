using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Cardence.Infrastructure.Migrations
{
    /// <inheritdoc />
    public partial class AddEventGroupCardInvites : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "event_group_card_invites",
                columns: table => new
                {
                    id = table.Column<Guid>(type: "uuid", nullable: false),
                    event_group_id = table.Column<Guid>(type: "uuid", nullable: false),
                    inviter_user_id = table.Column<Guid>(type: "uuid", nullable: false),
                    invitee_user_id = table.Column<Guid>(type: "uuid", nullable: false),
                    card_entity_id = table.Column<Guid>(type: "uuid", nullable: false),
                    card_id = table.Column<string>(type: "character varying(64)", maxLength: 64, nullable: false),
                    status = table.Column<string>(type: "character varying(20)", maxLength: 20, nullable: false),
                    created_at_utc = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    responded_at_utc = table.Column<DateTime>(type: "timestamp with time zone", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_event_group_card_invites", x => x.id);
                    table.ForeignKey(
                        name: "FK_event_group_card_invites_cards_card_entity_id",
                        column: x => x.card_entity_id,
                        principalTable: "cards",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_event_group_card_invites_event_groups_event_group_id",
                        column: x => x.event_group_id,
                        principalTable: "event_groups",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_event_group_card_invites_users_invitee_user_id",
                        column: x => x.invitee_user_id,
                        principalTable: "users",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_event_group_card_invites_users_inviter_user_id",
                        column: x => x.inviter_user_id,
                        principalTable: "users",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateIndex(
                name: "IX_event_group_card_invites_card_entity_id",
                table: "event_group_card_invites",
                column: "card_entity_id");

            migrationBuilder.CreateIndex(
                name: "IX_event_group_card_invites_event_group_id_card_entity_id_stat~",
                table: "event_group_card_invites",
                columns: new[] { "event_group_id", "card_entity_id", "status" });

            migrationBuilder.CreateIndex(
                name: "IX_event_group_card_invites_invitee_user_id_status",
                table: "event_group_card_invites",
                columns: new[] { "invitee_user_id", "status" });

            migrationBuilder.CreateIndex(
                name: "IX_event_group_card_invites_inviter_user_id",
                table: "event_group_card_invites",
                column: "inviter_user_id");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "event_group_card_invites");
        }
    }
}
