using Cardence.Application.DTOs.Wallet;
using Cardence.Domain.Constants;
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
        Address = entity.Address,
        City = entity.City,
        Country = entity.Country,
        Department = entity.Department,
        AttendedEvents = entity.AttendedEvents,
        Twitter = entity.Twitter,
        Instagram = entity.Instagram,
        Birthday = entity.Birthday,
        Note = entity.Note,
        SourceType = CardCreationMethods.ToLegacySourceType(entity.CreationMethod),
        CreationMethod = entity.CreationMethod,
        PhotoUrl = entity.PhotoUrl,
        AccentColor = entity.AccentColor,
        BackgroundColor = entity.BackgroundColor,
        SavedAt = entity.SavedAt,
        IsOwnerPremium = entity.IsOwnerPremium,
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
        entity.Address = dto.Address;
        entity.City = dto.City;
        entity.Country = dto.Country;
        entity.Department = dto.Department;
        entity.AttendedEvents = dto.AttendedEvents;
        entity.Twitter = dto.Twitter;
        entity.Instagram = dto.Instagram;
        entity.Birthday = dto.Birthday;
        entity.Note = dto.Note;
        entity.CreationMethod = CardCreationMethods.NormalizeWallet(
            dto.CreationMethod,
            dto.SourceType,
            dto.CardId,
            fromQrPayload: false);
        entity.PhotoUrl = dto.PhotoUrl;
        entity.AccentColor = dto.AccentColor;
        entity.BackgroundColor = dto.BackgroundColor;
        entity.LinkedEventGroupIds = dto.LinkedEventGroupIds.ToList();
    }

    public static void ApplyManualProfile(SavedCard entity, SavedCardDto dto)
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
        entity.Address = dto.Address;
        entity.City = dto.City;
        entity.Country = dto.Country;
        entity.Department = dto.Department;
        entity.AttendedEvents = dto.AttendedEvents;
        entity.Twitter = dto.Twitter;
        entity.Instagram = dto.Instagram;
        entity.Birthday = dto.Birthday;
        entity.AccentColor = dto.AccentColor;
        entity.BackgroundColor = dto.BackgroundColor;
        if (!string.IsNullOrWhiteSpace(dto.CreationMethod))
        {
            entity.CreationMethod = CardCreationMethods.NormalizeWallet(
                dto.CreationMethod,
                dto.SourceType,
                dto.CardId,
                fromQrPayload: false);
        }
    }

    public static void ApplyExtendedProfile(SavedCard entity, SavedCardDto dto)
    {
        entity.Address = dto.Address;
        entity.City = dto.City;
        entity.Country = dto.Country;
        entity.Department = dto.Department;
        entity.AttendedEvents = dto.AttendedEvents;
        entity.Twitter = dto.Twitter;
        entity.Instagram = dto.Instagram;
        entity.Birthday = dto.Birthday;
        entity.School = dto.School;
        entity.About = dto.About;
        entity.Skills = dto.Skills;
    }

    public static void HydrateFromOwnCard(SavedCard walletCard, Card source)
    {
        walletCard.DisplayName = source.DisplayName;
        walletCard.Email = source.Email;
        walletCard.Phone = source.Phone;
        walletCard.Company = source.Company;
        walletCard.Title = source.Title;
        walletCard.Website = source.Website;
        walletCard.Linkedin = source.Linkedin;
        walletCard.AccentColor = source.AccentColor;
        walletCard.BackgroundColor = source.BackgroundColor;
        walletCard.PhotoUrl = source.PhotoUrl;
        walletCard.CreationMethod = CardCreationMethods.CardenceLink;

        MergeOptionalField(source.Skills, v => walletCard.Skills = v);
        MergeOptionalField(source.School, v => walletCard.School = v);
        MergeOptionalField(source.About, v => walletCard.About = v);
        MergeOptionalField(source.Address, v => walletCard.Address = v);
        MergeOptionalField(source.City, v => walletCard.City = v);
        MergeOptionalField(source.Country, v => walletCard.Country = v);
        MergeOptionalField(source.Department, v => walletCard.Department = v);
        MergeOptionalField(source.AttendedEvents, v => walletCard.AttendedEvents = v);
        MergeOptionalField(source.Twitter, v => walletCard.Twitter = v);
        MergeOptionalField(source.Instagram, v => walletCard.Instagram = v);
        MergeOptionalField(source.Birthday, v => walletCard.Birthday = v);
    }

    private static void MergeOptionalField(string? sourceValue, Action<string?> assign)
    {
        if (!string.IsNullOrWhiteSpace(sourceValue))
        {
            assign(sourceValue.Trim());
        }
    }
}
