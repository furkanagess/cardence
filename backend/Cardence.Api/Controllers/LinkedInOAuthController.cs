using Microsoft.AspNetCore.Mvc;

namespace Cardence.Api.Controllers;

/// <summary>
/// LinkedIn OAuth redirect hedefi. Mobil WebView code parametresini yakalar;
/// tarayıcıda açılırsa kullanıcıya kısa bir onay sayfası gösterilir.
/// </summary>
[ApiController]
[Route("auth/linkedin")]
[Tags("Authentication")]
public sealed class LinkedInOAuthController : ControllerBase
{
    [HttpGet("callback")]
    [Produces("text/html")]
    public ContentResult Callback()
    {
        const string html = """
            <!DOCTYPE html>
            <html lang="tr">
            <head>
              <meta charset="utf-8" />
              <meta name="viewport" content="width=device-width, initial-scale=1" />
              <title>Cardence</title>
              <style>
                body { font-family: system-ui, sans-serif; margin: 2rem; color: #1c2430; }
              </style>
            </head>
            <body>
              <p>Giriş tamamlandı. Cardence uygulamasına dönebilirsiniz.</p>
            </body>
            </html>
            """;

        return Content(html, "text/html; charset=utf-8");
    }
}
