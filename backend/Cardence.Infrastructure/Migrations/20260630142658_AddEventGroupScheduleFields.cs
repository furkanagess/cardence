using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Cardence.Infrastructure.Migrations
{
    /// <inheritdoc />
    public partial class AddEventGroupScheduleFields : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<DateTime>(
                name: "end_at_utc",
                table: "event_groups",
                type: "timestamp with time zone",
                nullable: true);

            migrationBuilder.AddColumn<DateTime>(
                name: "start_at_utc",
                table: "event_groups",
                type: "timestamp with time zone",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "timezone",
                table: "event_groups",
                type: "character varying(80)",
                maxLength: 80,
                nullable: true);

            migrationBuilder.Sql("""
                UPDATE event_groups
                SET start_at_utc = COALESCE(event_date, created_at, NOW())
                WHERE start_at_utc IS NULL;
                """);

            migrationBuilder.AlterColumn<DateTime>(
                name: "start_at_utc",
                table: "event_groups",
                type: "timestamp with time zone",
                nullable: false,
                oldClrType: typeof(DateTime),
                oldType: "timestamp with time zone",
                oldNullable: true);

            migrationBuilder.CreateIndex(
                name: "IX_event_groups_user_id_end_at_utc",
                table: "event_groups",
                columns: new[] { "user_id", "end_at_utc" });

            migrationBuilder.CreateIndex(
                name: "IX_event_groups_user_id_start_at_utc",
                table: "event_groups",
                columns: new[] { "user_id", "start_at_utc" });
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropIndex(
                name: "IX_event_groups_user_id_end_at_utc",
                table: "event_groups");

            migrationBuilder.DropIndex(
                name: "IX_event_groups_user_id_start_at_utc",
                table: "event_groups");

            migrationBuilder.DropColumn(
                name: "end_at_utc",
                table: "event_groups");

            migrationBuilder.DropColumn(
                name: "start_at_utc",
                table: "event_groups");

            migrationBuilder.DropColumn(
                name: "timezone",
                table: "event_groups");
        }
    }
}
