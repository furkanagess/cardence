using Cardence.Application.DTOs.Wallet;
using Cardence.Domain.Entities;

namespace Cardence.Application.Mapping;

public static class SavedCardMapper
{
    public static SavedCardDto ToDto(SavedCard entity) => new()
    {
        CardId = entity.CardId,
        DisplayName = entity.DisplayName,
        Email = entity.Email,
        Phone = entity.Phone,
        Company = entity.Company,
        Title = entity.Title,
        Website = entity.Website,
        Linkedin = entity.Linkedin,
        Skills = entity.Skills,
        School = entity.School,
        About = entity.About,
        Note = entity.Note,
        AccentColor = entity.AccentColor,
        BackgroundColor = entity.BackgroundColor,
        SavedAt = entity.SavedAt,
        LinkedEventGroupIds = entity.LinkedEventGroupIds,
    };

    public static void ApplyDto(SavedCard entity, SavedCardDto dto)
    {
        entity.DisplayName = dto.DisplayName;
        entity.Email = dto.Email;
        entity.Phone = dto.Phone;
        entity.Company = dto.Company;
        entity.Title = dto.Title;
        entity.Website = dto.Website;
        entity.Linkedin = dto.Linkedin;
        entity.Skills = dto.Skills;
        entity.School = dto.School;
        entity.About = dto.About;
        entity.Note = dto.Note;
        entity.AccentColor = dto.AccentColor;
        entity.BackgroundColor = dto.BackgroundColor;
        entity.LinkedEventGroupIds = dto.LinkedEventGroupIds.ToList();
    }

    /// <summary>
    /// Kaynak kart business_cards tablosundaysa profil alanlarını DB'den uygular.
    /// </summary>
    public static void HydrateFromBusinessCard(SavedCard entity, BusinessCard source)
    {
        entity.DisplayName = source.DisplayName;
        entity.Email = source.Email;
        entity.Phone = source.Phone;
        entity.Company = source.Company;
        entity.Title = source.Title;
        entity.Website = source.Website;
        entity.Linkedin = source.Linkedin;
        entity.Skills = source.Skills;
        entity.School = source.School;
        entity.About = source.About;
        entity.AccentColor = source.AccentColor;
        entity.BackgroundColor = source.BackgroundColor;
    }
}
