using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Cardence.Infrastructure.Migrations
{
    /// <inheritdoc />
    public partial class AddWalletCardInvites : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "wallet_card_invites",
                columns: table => new
                {
                    id = table.Column<Guid>(type: "uuid", nullable: false),
                    inviter_user_id = table.Column<Guid>(type: "uuid", nullable: false),
                    invitee_user_id = table.Column<Guid>(type: "uuid", nullable: false),
                    proposed_card_entity_id = table.Column<Guid>(type: "uuid", nullable: false),
                    proposed_card_id = table.Column<string>(type: "character varying(6)", maxLength: 6, nullable: false),
                    saved_card_id = table.Column<string>(type: "character varying(6)", maxLength: 6, nullable: false),
                    status = table.Column<string>(type: "character varying(20)", maxLength: 20, nullable: false),
                    created_at_utc = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    expires_at_utc = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    responded_at_utc = table.Column<DateTime>(type: "timestamp with time zone", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_wallet_card_invites", x => x.id);
                    table.ForeignKey(
                        name: "FK_wallet_card_invites_cards_proposed_card_entity_id",
                        column: x => x.proposed_card_entity_id,
                        principalTable: "cards",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_wallet_card_invites_users_invitee_user_id",
                        column: x => x.invitee_user_id,
                        principalTable: "users",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_wallet_card_invites_users_inviter_user_id",
                        column: x => x.inviter_user_id,
                        principalTable: "users",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateIndex(
                name: "IX_wallet_card_invites_expires_at_utc",
                table: "wallet_card_invites",
                column: "expires_at_utc");

            migrationBuilder.CreateIndex(
                name: "IX_wallet_card_invites_invitee_user_id_inviter_user_id_status",
                table: "wallet_card_invites",
                columns: new[] { "invitee_user_id", "inviter_user_id", "status" });

            migrationBuilder.CreateIndex(
                name: "IX_wallet_card_invites_invitee_user_id_status",
                table: "wallet_card_invites",
                columns: new[] { "invitee_user_id", "status" });

            migrationBuilder.CreateIndex(
                name: "IX_wallet_card_invites_inviter_user_id",
                table: "wallet_card_invites",
                column: "inviter_user_id");

            migrationBuilder.CreateIndex(
                name: "IX_wallet_card_invites_proposed_card_entity_id",
                table: "wallet_card_invites",
                column: "proposed_card_entity_id");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "wallet_card_invites");
        }
    }
}
