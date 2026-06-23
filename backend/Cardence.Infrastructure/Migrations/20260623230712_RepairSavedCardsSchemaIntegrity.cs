using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Cardence.Infrastructure.Migrations
{
    /// <inheritdoc />
    public partial class RepairSavedCardsSchemaIntegrity : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.Sql("""
                ALTER TABLE saved_cards
                    ADD COLUMN IF NOT EXISTS is_owner_premium boolean NOT NULL DEFAULT false;

                ALTER TABLE cards
                    ADD COLUMN IF NOT EXISTS is_owner_premium boolean NOT NULL DEFAULT false;

                CREATE INDEX IF NOT EXISTS "IX_saved_cards_user_id_is_owner_premium"
                    ON saved_cards (user_id, is_owner_premium);

                UPDATE cards c
                SET is_owner_premium = true
                FROM wallet_entitlements w
                WHERE c.user_id = w."UserId"
                  AND LOWER(w.tier) = 'premium'
                  AND c.is_owner_premium IS DISTINCT FROM true;

                UPDATE saved_cards sc
                SET is_owner_premium = true
                FROM cards c
                INNER JOIN wallet_entitlements w ON c.user_id = w."UserId"
                WHERE sc.card_id = c.card_id
                  AND LOWER(w.tier) = 'premium'
                  AND sc.is_owner_premium IS DISTINCT FROM true;
                """);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            // Repair migration; no down action.
        }
    }
}
