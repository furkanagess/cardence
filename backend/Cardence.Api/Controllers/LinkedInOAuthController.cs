using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.WebUtilities;

namespace Cardence.Api.Controllers;

/// <summary>
/// LinkedIn OAuth redirect hedefi. Mobil uygulama deep link ile authorization code alır;
/// tarayıcıda açılırsa kısa bir onay sayfası gösterilir.
/// </summary>
[ApiController]
[AllowAnonymous]
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
              <meta name="robots" content="noindex" />
              <title>Giriş tamamlandı · Cardence</title>
              <style>
                :root {
                  --bg: #f4f5f7;
                  --surface: #ffffff;
                  --primary: #1b365d;
                  --primary-light: #2e4a73;
                  --success: #1f6b4f;
                  --success-bg: #e3f1ea;
                  --text-primary: #1c2430;
                  --text-secondary: #5a6578;
                  --outline: #dde2e9;
                }
                @media (prefers-color-scheme: dark) {
                  :root {
                    --bg: #0f1419;
                    --surface: #1a2028;
                    --primary: #8fa8c4;
                    --primary-light: #a8bdd6;
                    --success: #5fbf97;
                    --success-bg: #16271f;
                    --text-primary: #eceff4;
                    --text-secondary: #a8b0bd;
                    --outline: #28303a;
                  }
                }
                * { box-sizing: border-box; }
                html, body { height: 100%; }
                body {
                  margin: 0;
                  font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", system-ui, sans-serif;
                  background: var(--bg);
                  color: var(--text-primary);
                  display: flex;
                  align-items: center;
                  justify-content: center;
                  padding: 24px;
                  line-height: 1.5;
                }
                .card {
                  width: 100%;
                  max-width: 420px;
                  background: var(--surface);
                  border: 1px solid var(--outline);
                  border-radius: 20px;
                  padding: 32px 28px;
                  text-align: center;
                  box-shadow: 0 12px 32px rgba(27, 54, 93, 0.10);
                }
                .badge {
                  width: 72px;
                  height: 72px;
                  margin: 0 auto 20px;
                  border-radius: 50%;
                  background: var(--success-bg);
                  display: flex;
                  align-items: center;
                  justify-content: center;
                }
                .badge svg { width: 38px; height: 38px; }
                .brand {
                  font-size: 0.8rem;
                  font-weight: 600;
                  letter-spacing: 0.12em;
                  text-transform: uppercase;
                  color: var(--primary-light);
                  margin-bottom: 6px;
                }
                h1 {
                  font-size: 1.4rem;
                  margin: 0 0 10px;
                  color: var(--text-primary);
                }
                p {
                  margin: 0 0 8px;
                  color: var(--text-secondary);
                  font-size: 0.98rem;
                }
                .hint {
                  margin-top: 20px;
                  padding: 14px 16px;
                  background: var(--bg);
                  border: 1px solid var(--outline);
                  border-radius: 12px;
                  font-size: 0.86rem;
                  color: var(--text-secondary);
                }
                .hint strong { color: var(--text-primary); }
                .footer {
                  margin-top: 22px;
                  font-size: 0.78rem;
                  color: var(--text-secondary);
                  opacity: 0.8;
                }
              </style>
            </head>
            <body>
              <main class="card" role="status" aria-live="polite">
                <div class="badge" aria-hidden="true">
                  <svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                    <path d="M20 6 9 17l-5-5" stroke="#1f6b4f" stroke-width="2.4"
                      stroke-linecap="round" stroke-linejoin="round" />
                  </svg>
                </div>
                <div class="brand">Cardence</div>
                <h1>Giriş tamamlandı</h1>
                <p>LinkedIn hesabınla giriş başarıyla doğrulandı.</p>
                <p>Şimdi Cardence uygulamasına geri dönebilirsin.</p>
                <div class="hint">
                  Uygulama otomatik açılmadıysa bu sekmeyi kapatıp
                  <strong>Cardence</strong> uygulamasına elle dönmen yeterli.
                </div>
                <div class="footer">Bu pencereyi güvenle kapatabilirsin.</div>
              </main>
            </body>
            </html>
            """;

        return Content(html, "text/html; charset=utf-8");
    }
}
