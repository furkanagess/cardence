namespace Cardence.Application.Options;

public sealed class EmailOptions
{
    public const string SectionName = "Email";

    public string FromName { get; init; } = "Cardence";
    public string FromAddress { get; init; } = "noreply@cardenceapi.app";
    public string SmtpHost { get; init; } = string.Empty;
    public int SmtpPort { get; init; } = 587;
    public string SmtpUsername { get; init; } = string.Empty;
    public string SmtpPassword { get; init; } = string.Empty;
    public bool UseSsl { get; init; } = true;

    /// <summary>
    /// SMTP host, gönderen adresi ve şifre tanımlıysa mail gönderimi aktiftir.
    /// SendGrid: SmtpHost=smtp.sendgrid.net, SmtpUsername=apikey, SmtpPassword=SG.xxx
    /// </summary>
    public bool IsConfigured =>
        !string.IsNullOrWhiteSpace(SmtpHost)
        && !string.IsNullOrWhiteSpace(FromAddress)
        && !string.IsNullOrWhiteSpace(SmtpPassword);
}
