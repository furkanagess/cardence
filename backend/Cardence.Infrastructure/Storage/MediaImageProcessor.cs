using Cardence.Application.Common;
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.Formats.Jpeg;
using SixLabors.ImageSharp.Processing;

namespace Cardence.Infrastructure.Storage;

/// <summary>
/// Yüklenen görselleri sıkıştırılmış JPEG varyantlarına dönüştürür.
/// </summary>
public static class MediaImageProcessor
{
    private const int JpegQuality = 82;

    public static async Task<IReadOnlyDictionary<string, byte[]>> CreateProfileVariantsAsync(
        Stream content,
        CancellationToken cancellationToken = default)
    {
        return await CreateVariantsAsync(content, "profile", cancellationToken);
    }

    public static async Task<IReadOnlyDictionary<string, byte[]>> CreateEventGroupVariantsAsync(
        Stream content,
        Guid groupId,
        CancellationToken cancellationToken = default)
    {
        return await CreateVariantsAsync(content, groupId.ToString("D"), cancellationToken);
    }

    public static async Task SaveProfileVariantsAsync(
        Stream content,
        string userDirectory,
        CancellationToken cancellationToken = default)
    {
        Directory.CreateDirectory(userDirectory);
        DeleteExistingProfileFiles(userDirectory);

        var variants = await CreateProfileVariantsAsync(content, cancellationToken);
        foreach (var (fileName, bytes) in variants)
        {
            var path = Path.Combine(userDirectory, fileName);
            await File.WriteAllBytesAsync(path, bytes, cancellationToken);
        }
    }

    public static async Task SaveEventGroupVariantsAsync(
        Stream content,
        string groupDirectory,
        Guid groupId,
        CancellationToken cancellationToken = default)
    {
        Directory.CreateDirectory(groupDirectory);
        DeleteExistingEventGroupFiles(groupDirectory, groupId);

        var variants = await CreateEventGroupVariantsAsync(content, groupId, cancellationToken);
        foreach (var (fileName, bytes) in variants)
        {
            var path = Path.Combine(groupDirectory, fileName);
            await File.WriteAllBytesAsync(path, bytes, cancellationToken);
        }
    }

    private static async Task<IReadOnlyDictionary<string, byte[]>> CreateVariantsAsync(
        Stream content,
        string baseName,
        CancellationToken cancellationToken)
    {
        await using var buffer = new MemoryStream();
        await content.CopyToAsync(buffer, cancellationToken);
        buffer.Position = 0;

        using var image = await Image.LoadAsync(buffer, cancellationToken);
        image.Mutate(x => x.AutoOrient());

        var encoder = new JpegEncoder
        {
            Quality = JpegQuality,
        };

        var variants = new Dictionary<string, byte[]>(StringComparer.Ordinal);
        foreach (var width in MediaVariantWidths.All)
        {
            using var resized = image.Clone(ctx => ctx.Resize(new ResizeOptions
            {
                Size = new Size(width, width),
                Mode = ResizeMode.Max,
            }));

            await using var output = new MemoryStream();
            await resized.SaveAsJpegAsync(output, encoder, cancellationToken);
            variants[$"{baseName}-{width}.jpg"] = output.ToArray();
        }

        return variants;
    }

    private static void DeleteExistingProfileFiles(string userDirectory)
    {
        if (!Directory.Exists(userDirectory))
        {
            return;
        }

        foreach (var file in Directory.EnumerateFiles(userDirectory, "profile*"))
        {
            File.Delete(file);
        }
    }

    private static void DeleteExistingEventGroupFiles(string groupDirectory, Guid groupId)
    {
        if (!Directory.Exists(groupDirectory))
        {
            return;
        }

        var prefix = $"{groupId:D}";
        foreach (var file in Directory.EnumerateFiles(groupDirectory, $"{prefix}*"))
        {
            File.Delete(file);
        }
    }
}
