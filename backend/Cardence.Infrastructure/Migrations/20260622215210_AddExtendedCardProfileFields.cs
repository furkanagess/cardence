using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Cardence.Infrastructure.Migrations
{
    /// <inheritdoc />
    public partial class AddExtendedCardProfileFields : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "address",
                table: "saved_cards",
                type: "character varying(500)",
                maxLength: 500,
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "attended_events",
                table: "saved_cards",
                type: "text",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "birthday",
                table: "saved_cards",
                type: "character varying(50)",
                maxLength: 50,
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "city",
                table: "saved_cards",
                type: "character varying(120)",
                maxLength: 120,
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "country",
                table: "saved_cards",
                type: "character varying(120)",
                maxLength: 120,
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "department",
                table: "saved_cards",
                type: "character varying(200)",
                maxLength: 200,
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "instagram",
                table: "saved_cards",
                type: "character varying(500)",
                maxLength: 500,
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "twitter",
                table: "saved_cards",
                type: "character varying(500)",
                maxLength: 500,
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "address",
                table: "business_cards",
                type: "character varying(500)",
                maxLength: 500,
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "attended_events",
                table: "business_cards",
                type: "text",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "birthday",
                table: "business_cards",
                type: "character varying(50)",
                maxLength: 50,
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "city",
                table: "business_cards",
                type: "character varying(120)",
                maxLength: 120,
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "country",
                table: "business_cards",
                type: "character varying(120)",
                maxLength: 120,
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "department",
                table: "business_cards",
                type: "character varying(200)",
                maxLength: 200,
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "instagram",
                table: "business_cards",
                type: "character varying(500)",
                maxLength: 500,
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "twitter",
                table: "business_cards",
                type: "character varying(500)",
                maxLength: 500,
                nullable: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "address",
                table: "saved_cards");

            migrationBuilder.DropColumn(
                name: "attended_events",
                table: "saved_cards");

            migrationBuilder.DropColumn(
                name: "birthday",
                table: "saved_cards");

            migrationBuilder.DropColumn(
                name: "city",
                table: "saved_cards");

            migrationBuilder.DropColumn(
                name: "country",
                table: "saved_cards");

            migrationBuilder.DropColumn(
                name: "department",
                table: "saved_cards");

            migrationBuilder.DropColumn(
                name: "instagram",
                table: "saved_cards");

            migrationBuilder.DropColumn(
                name: "twitter",
                table: "saved_cards");

            migrationBuilder.DropColumn(
                name: "address",
                table: "business_cards");

            migrationBuilder.DropColumn(
                name: "attended_events",
                table: "business_cards");

            migrationBuilder.DropColumn(
                name: "birthday",
                table: "business_cards");

            migrationBuilder.DropColumn(
                name: "city",
                table: "business_cards");

            migrationBuilder.DropColumn(
                name: "country",
                table: "business_cards");

            migrationBuilder.DropColumn(
                name: "department",
                table: "business_cards");

            migrationBuilder.DropColumn(
                name: "instagram",
                table: "business_cards");

            migrationBuilder.DropColumn(
                name: "twitter",
                table: "business_cards");
        }
    }
}
