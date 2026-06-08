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
        entity.LinkedEventGroupIds = dto.LinkedEventGroupIds.ToList();
    }

    public static void HydrateFromBusinessCard(SavedCard entity, BusinessCard source)
    {
        entity.DisplayName ??= source.DisplayName;
        entity.Email ??= source.Email;
        entity.Phone ??= source.Phone;
        entity.Company ??= source.Company;
        entity.Title ??= source.Title;
        entity.Website ??= source.Website;
        entity.Linkedin ??= source.Linkedin;
        entity.Skills ??= source.Skills;
        entity.School ??= source.School;
    }
}
