using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.WebUtilities;

namespace Cardence.Api.Controllers;

/// <summary>
/// LinkedIn OAuth redirect hedefi. Mobil uygulama deep link ile authorization code alır;
/// tarayıcıda açılırsa kısa bir onay sayfası gösterilir.
/// </summary>
[ApiController]
[Route("auth/linkedin")]
[Tags("Authentication")]
public sealed class LinkedInOAuthController : ControllerBase
{
    private const string MobileCallbackScheme = "com.furkanages.cardenceapp";

    [HttpGet("callback")]
    [Produces("text/html")]
    public IActionResult Callback(
        [FromQuery] string? code,
        [FromQuery] string? state,
        [FromQuery] string? error,
        [FromQuery] string? error_description)
    {
        if (!string.IsNullOrWhiteSpace(code))
        {
            var mobileCallback = QueryHelpers.AddQueryString(
                $"{MobileCallbackScheme}://auth/linkedin/callback",
                new Dictionary<string, string?>
                {
                    ["code"] = code,
                    ["state"] = state,
                });

            return Redirect(mobileCallback);
        }

        if (!string.IsNullOrWhiteSpace(error))
        {
            var mobileErrorCallback = QueryHelpers.AddQueryString(
                $"{MobileCallbackScheme}://auth/linkedin/callback",
                new Dictionary<string, string?>
                {
                    ["error"] = error,
                    ["error_description"] = error_description,
                    ["state"] = state,
                });

            return Redirect(mobileErrorCallback);
        }

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
