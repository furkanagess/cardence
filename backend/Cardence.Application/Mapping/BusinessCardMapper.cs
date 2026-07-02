using Cardence.Application.DTOs.Cards;
using Cardence.Domain.Entities;

namespace Cardence.Application.Mapping;

public static class BusinessCardMapper
{
    public static BusinessCardDto ToDto(Card entity) => new()
    {
        CardName = entity.CardName,
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
        PhotoUrl = entity.PhotoUrl,
        AccentColor = entity.AccentColor,
        BackgroundColor = entity.BackgroundColor,
        CardEffect = entity.CardEffect,
        LinkedEventGroupIds = [],
        CardId = entity.CardId,
        IsOwnerPremium = entity.IsOwnerPremium,
    };

    public static void ApplyDto(Card entity, BusinessCardDto dto)
    {
        entity.CardName = dto.CardName;
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
        entity.PhotoUrl = dto.PhotoUrl;
        entity.AccentColor = dto.AccentColor;
        entity.BackgroundColor = dto.BackgroundColor;
        entity.CardEffect = dto.CardEffect;
        entity.UpdatedAt = DateTime.UtcNow;
    }

    public static Dictionary<string, object?> ToSharePayload(Card entity)
    {
        var payload = new Dictionary<string, object?> { ["id"] = entity.CardId };

        AddIfNotEmpty(payload, "n", entity.DisplayName);
        AddIfNotEmpty(payload, "e", entity.Email);
        AddIfNotEmpty(payload, "p", entity.Phone);
        AddIfNotEmpty(payload, "c", entity.Company);
        AddIfNotEmpty(payload, "t", entity.Title);
        AddIfNotEmpty(payload, "w", entity.Website);
        AddIfNotEmpty(payload, "l", entity.Linkedin);
        AddIfNotEmpty(payload, "s", entity.Skills);
        AddIfNotEmpty(payload, "o", entity.School);
        AddIfNotEmpty(payload, "h", entity.About);
        AddIfNotEmpty(payload, "a", entity.Address);
        AddIfNotEmpty(payload, "ci", entity.City);
        AddIfNotEmpty(payload, "co", entity.Country);
        AddIfNotEmpty(payload, "d", entity.Department);
        AddIfNotEmpty(payload, "ae", entity.AttendedEvents);
        AddIfNotEmpty(payload, "tw", entity.Twitter);
        AddIfNotEmpty(payload, "ig", entity.Instagram);
        AddIfNotEmpty(payload, "bd", entity.Birthday);
        AddIfNotEmpty(payload, "ph", entity.PhotoUrl);
        AddIfNotEmpty(payload, "tc", entity.AccentColor);
        AddIfNotEmpty(payload, "bc", entity.BackgroundColor);

        return payload;
    }

    private static void AddIfNotEmpty(Dictionary<string, object?> payload, string key, string? value)
    {
        if (!string.IsNullOrWhiteSpace(value))
        {
            payload[key] = value;
        }
    }
}
