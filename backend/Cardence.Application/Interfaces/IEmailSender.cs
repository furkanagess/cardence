namespace Cardence.Application.Interfaces;

public interface IEmailSender
{
    Task SendPasswordResetEmailAsync(
        string toEmail,
        string resetUrl,
        CancellationToken cancellationToken = default);
}
