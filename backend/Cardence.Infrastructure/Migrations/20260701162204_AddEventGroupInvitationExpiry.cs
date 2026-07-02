using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Cardence.Infrastructure.Migrations
{
    /// <inheritdoc />
    public partial class AddEventGroupInvitationExpiry : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<DateTime>(
                name: "expires_at_utc",
                table: "event_group_card_invites",
                type: "timestamp with time zone",
                nullable: true);

            migrationBuilder.Sql(
                """
                UPDATE event_group_card_invites
                SET expires_at_utc = created_at_utc + INTERVAL '7 days'
                WHERE expires_at_utc IS NULL;
                """);

            migrationBuilder.Sql(
                """
                DELETE FROM event_group_card_invites
                WHERE expires_at_utc <= NOW() AT TIME ZONE 'utc';
                """);

            migrationBuilder.AlterColumn<DateTime>(
                name: "expires_at_utc",
                table: "event_group_card_invites",
                type: "timestamp with time zone",
                nullable: false,
                oldClrType: typeof(DateTime),
                oldType: "timestamp with time zone",
                oldNullable: true);

            migrationBuilder.CreateIndex(
                name: "IX_event_group_card_invites_expires_at_utc",
                table: "event_group_card_invites",
                column: "expires_at_utc");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropIndex(
                name: "IX_event_group_card_invites_expires_at_utc",
                table: "event_group_card_invites");

            migrationBuilder.DropColumn(
                name: "expires_at_utc",
                table: "event_group_card_invites");
        }
    }
}
