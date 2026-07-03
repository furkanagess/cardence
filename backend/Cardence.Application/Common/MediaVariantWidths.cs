namespace Cardence.Application.Common;

/// <summary>
/// Sunucuda üretilen görsel varyant genişlikleri (px). Uzun kenar bu değeri aşmaz.
/// </summary>
public static class MediaVariantWidths
{
    public const int Thumb = 128;
    public const int Small = 256;
    public const int Medium = 512;
    public const int Large = 1024;

    public static readonly int[] All = [Thumb, Small, Medium, Large];

    /// <summary>Kart listesi / avatar için önerilen varsayılan.</summary>
    public const int DefaultProfile = Small;

    /// <summary>Kart yüzü ve detay başlığı için önerilen varsayılan.</summary>
    public const int DefaultCard = Medium;

    /// <summary>Etkinlik kapak önizlemesi için önerilen varsayılan.</summary>
    public const int DefaultEventCover = Medium;
}
