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
            // SplitSavedCardsFromCardsTable never created source_card_id on saved_cards;
            // use idempotent drops so fresh databases and partial deploys both succeed.
            migrationBuilder.Sql("""
                ALTER TABLE saved_cards
                    DROP CONSTRAINT IF EXISTS "FK_saved_cards_cards_source_card_id";

                DROP INDEX IF EXISTS "IX_saved_cards_source_card_id";

                ALTER TABLE saved_cards
                    DROP COLUMN IF EXISTS source_card_id;
                """);
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
