using Cardence.Application.Interfaces;
using Cardence.Application.Mapping;
using Cardence.Domain.Constants;
using Cardence.Domain.Entities;

namespace Cardence.Application.Common;

public static class SavedCardEnrichment
{
    public static async Task HydrateLinkedProfilesAndPremiumAsync(
        IReadOnlyList<Card> cards,
        IBusinessCardRepository businessCardRepository,
        IWalletEntitlementRepository walletRepository,
        CancellationToken cancellationToken = default)
    {
        foreach (var card in cards)
        {
            if (!CardRoles.IsWallet(card.CardRole) ||
                CardCreationMethods.IsManualEntry(card.CreationMethod))
            {
                card.IsOwnerPremium = false;
                continue;
            }

            var ownCard = await businessCardRepository.GetByCardIdAsync(
                card.CardId,
                cancellationToken);
            if (ownCard is null)
            {
                card.IsOwnerPremium = false;
                continue;
            }

            var note = card.Note;
            SavedCardMapper.HydrateFromOwnCard(card, ownCard);
            card.Note = note;
            card.IsOwnerPremium = await IsUserPremiumAsync(
                walletRepository,
                ownCard.UserId,
                cancellationToken);
        }
    }

    public static async Task<bool> IsUserPremiumAsync(
        IWalletEntitlementRepository walletRepository,
        Guid userId,
        CancellationToken cancellationToken)
    {
        var entitlement = await walletRepository.GetOrCreateAsync(userId, cancellationToken);
        return WalletConstants.HasUnlimitedWalletCards(entitlement.Tier);
    }

    public static IReadOnlyList<Card> SortForWalletDisplay(IReadOnlyList<Card> cards) =>
        cards
            .OrderByDescending(card => card.IsOwnerPremium)
            .ThenBy(card => card.SortOrder)
            .ThenByDescending(card => card.SavedAt)
            .ToList();
}
