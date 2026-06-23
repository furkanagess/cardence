using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Cardence.Infrastructure.Migrations
{
    /// <inheritdoc />
    public partial class AddIsOwnerPremiumToCards : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<bool>(
                name: "is_owner_premium",
                table: "saved_cards",
                type: "boolean",
                nullable: false,
                defaultValue: false);

            migrationBuilder.AddColumn<bool>(
                name: "is_owner_premium",
                table: "cards",
                type: "boolean",
                nullable: false,
                defaultValue: false);

            migrationBuilder.CreateIndex(
                name: "IX_saved_cards_user_id_is_owner_premium",
                table: "saved_cards",
                columns: new[] { "user_id", "is_owner_premium" });

            migrationBuilder.Sql("""
                UPDATE cards c
                SET is_owner_premium = true
                FROM wallet_entitlements w
                WHERE c.user_id = w."UserId"
                  AND LOWER(w.tier) = 'premium';
                """);

            migrationBuilder.Sql("""
                UPDATE saved_cards sc
                SET is_owner_premium = true
                FROM cards c
                INNER JOIN wallet_entitlements w ON c.user_id = w."UserId"
                WHERE sc.card_id = c.card_id
                  AND LOWER(w.tier) = 'premium';
                """);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropIndex(
                name: "IX_saved_cards_user_id_is_owner_premium",
                table: "saved_cards");

            migrationBuilder.DropColumn(
                name: "is_owner_premium",
                table: "saved_cards");

            migrationBuilder.DropColumn(
                name: "is_owner_premium",
                table: "cards");
        }
    }
}
