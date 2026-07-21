namespace Cardence.Application.Options;

public sealed class AppleAuthOptions
{
    public const string SectionName = "AppleAuth";

    /// <summary>Bundle ID veya Services ID — identity token audience.</summary>
    public string ClientId { get; init; } = "com.furkanages.cardenceapp";
}
