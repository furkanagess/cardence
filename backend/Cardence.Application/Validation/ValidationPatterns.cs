namespace Cardence.Application.Validation;

public static class ValidationPatterns
{
    public const string PersonName = @"^[a-zA-ZğüşöçıİĞÜŞÖÇ][a-zA-ZğüşöçıİĞÜŞÖÇ'\-\.]{1,}$";
    public const string OrganizationText = @"^[a-zA-ZğüşöçıİĞÜŞÖÇ0-9][a-zA-ZğüşöçıİĞÜŞÖÇ0-9\s&\.,'\-]{1,}$";
    public const string Email = @"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$";
    public const string SkillToken = @"^[a-zA-ZğüşöçıİĞÜŞÖÇ0-9][a-zA-ZğüşöçıİĞÜŞÖÇ0-9+#./\-\s]{1,}$";
    public const string CardId = @"^[a-zA-Z0-9\-_]{8,}$";
    public const string HexColor = @"^#[0-9A-Fa-f]{6}$";
}
