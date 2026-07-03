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

    public static async Task SaveProfileVariantsAsync(
        Stream content,
        string userDirectory,
        CancellationToken cancellationToken = default)
    {
        Directory.CreateDirectory(userDirectory);
        DeleteExistingProfileFiles(userDirectory);

        await using var buffer = new MemoryStream();
        await content.CopyToAsync(buffer, cancellationToken);
        buffer.Position = 0;

        using var image = await Image.LoadAsync(buffer, cancellationToken);
        image.Mutate(x => x.AutoOrient());

        await WriteVariantsAsync(image, userDirectory, "profile", cancellationToken);
    }

    public static async Task SaveEventGroupVariantsAsync(
        Stream content,
        string groupDirectory,
        Guid groupId,
        CancellationToken cancellationToken = default)
    {
        Directory.CreateDirectory(groupDirectory);
        DeleteExistingEventGroupFiles(groupDirectory, groupId);

        await using var buffer = new MemoryStream();
        await content.CopyToAsync(buffer, cancellationToken);
        buffer.Position = 0;

        using var image = await Image.LoadAsync(buffer, cancellationToken);
        image.Mutate(x => x.AutoOrient());

        await WriteVariantsAsync(image, groupDirectory, groupId.ToString("D"), cancellationToken);
    }

    private static async Task WriteVariantsAsync(
        Image image,
        string directory,
        string baseName,
        CancellationToken cancellationToken)
    {
        var encoder = new JpegEncoder
        {
            Quality = JpegQuality,
        };

        foreach (var width in MediaVariantWidths.All)
        {
            using var resized = image.Clone(ctx => ctx.Resize(new ResizeOptions
            {
                Size = new Size(width, width),
                Mode = ResizeMode.Max,
            }));

            var path = Path.Combine(directory, $"{baseName}-{width}.jpg");
            await resized.SaveAsJpegAsync(path, encoder, cancellationToken);
        }
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
