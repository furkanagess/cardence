using Cardence.Application.Interfaces;
using Cardence.Application.Mapping;
using Cardence.Domain.Constants;
using Cardence.Domain.Entities;

namespace Cardence.Application.Common;

public static class SavedCardEnrichment
{
    public static async Task HydrateLinkedProfilesAsync(
        IReadOnlyList<SavedCard> cards,
        IBusinessCardRepository businessCardRepository,
        CancellationToken cancellationToken = default)
    {
        foreach (var card in cards)
        {
            if (CardCreationMethods.IsManualEntry(card.CreationMethod))
            {
                continue;
            }

            var ownCard = await businessCardRepository.GetByCardIdAsync(
                card.CardId,
                cancellationToken);
            if (ownCard is null)
            {
                continue;
            }

            var note = card.Note;
            SavedCardMapper.HydrateFromOwnCard(card, ownCard);
            card.Note = note;
        }
    }

    public static IReadOnlyList<SavedCard> SortForWalletDisplay(IReadOnlyList<SavedCard> cards) =>
        cards
            .OrderByDescending(card => card.IsOwnerPremium)
            .ThenBy(card => card.SortOrder)
            .ThenByDescending(card => card.SavedAt)
            .ToList();
}
