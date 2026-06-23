using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Cardence.Infrastructure.Migrations
{
    /// <inheritdoc />
    public partial class RemoveSavedCardSourceCardId : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_saved_cards_cards_source_card_id",
                table: "saved_cards");

            migrationBuilder.DropIndex(
                name: "IX_saved_cards_source_card_id",
                table: "saved_cards");

            migrationBuilder.DropColumn(
                name: "source_card_id",
                table: "saved_cards");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<Guid>(
                name: "source_card_id",
                table: "saved_cards",
                type: "uuid",
                nullable: true);

            migrationBuilder.CreateIndex(
                name: "IX_saved_cards_source_card_id",
                table: "saved_cards",
                column: "source_card_id");

            migrationBuilder.AddForeignKey(
                name: "FK_saved_cards_cards_source_card_id",
                table: "saved_cards",
                column: "source_card_id",
                principalTable: "cards",
                principalColumn: "Id",
                onDelete: ReferentialAction.SetNull);
        }
    }
}
