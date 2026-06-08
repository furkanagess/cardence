namespace Cardence.Application.Options;

public sealed class ApiOptions
{
    public const string SectionName = "Api";

    public string PublicBaseUrl { get; init; } = "https://cardenceapi.app";
}
