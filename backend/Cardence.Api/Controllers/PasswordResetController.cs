using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace Cardence.Api.Controllers;

/// <summary>
/// Maildeki sifre sifirlama linki icin web sayfasi.
/// Mobil uygulama deep link desteklemiyorsa kullanici buradan yeni sifre belirler.
/// </summary>
[ApiController]
[AllowAnonymous]
[Route("auth/reset-password")]
[Tags("Authentication")]
public sealed class PasswordResetController : ControllerBase
{
    [HttpGet]
    [Produces("text/html")]
    public IActionResult ResetPage([FromQuery] string? token, [FromQuery] string? email)
    {
        var safeToken = System.Net.WebUtility.HtmlEncode(token ?? string.Empty);
        var safeEmail = System.Net.WebUtility.HtmlEncode(email ?? string.Empty);

        var html = $$"""
            <!DOCTYPE html>
            <html lang="tr">
            <head>
              <meta charset="utf-8" />
              <meta name="viewport" content="width=device-width, initial-scale=1" />
              <title>Şifre sıfırla · Cardence</title>
              <style>
                :root {
                  --bg: #f4f5f7;
                  --surface: #ffffff;
                  --primary: #1b365d;
                  --text: #1c2430;
                  --muted: #5a6578;
                  --outline: #dde2e9;
                  --error: #b42318;
                }
                * { box-sizing: border-box; }
                body {
                  margin: 0;
                  min-height: 100vh;
                  font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
                  background: var(--bg);
                  color: var(--text);
                  display: flex;
                  align-items: center;
                  justify-content: center;
                  padding: 24px;
                }
                .card {
                  width: 100%;
                  max-width: 420px;
                  background: var(--surface);
                  border: 1px solid var(--outline);
                  border-radius: 20px;
                  padding: 28px;
                  box-shadow: 0 12px 32px rgba(27, 54, 93, 0.10);
                }
                h1 { margin: 0 0 8px; font-size: 1.35rem; }
                p { margin: 0 0 16px; color: var(--muted); line-height: 1.5; }
                label { display: block; font-size: 0.9rem; font-weight: 600; margin-bottom: 6px; }
                input {
                  width: 100%;
                  padding: 12px 14px;
                  border: 1px solid var(--outline);
                  border-radius: 12px;
                  font-size: 1rem;
                  margin-bottom: 14px;
                }
                button {
                  width: 100%;
                  padding: 14px;
                  border: none;
                  border-radius: 12px;
                  background: var(--primary);
                  color: white;
                  font-size: 1rem;
                  font-weight: 600;
                  cursor: pointer;
                }
                button:disabled { opacity: 0.6; cursor: not-allowed; }
                .message { margin-top: 14px; font-size: 0.92rem; }
                .error { color: var(--error); }
                .success { color: #1f6b4f; }
              </style>
            </head>
            <body>
              <main class="card">
                <h1>Yeni şifre belirle</h1>
                <p>Cardence hesabınız için yeni şifrenizi girin.</p>
                <form id="reset-form">
                  <input type="hidden" id="token" value="{{safeToken}}" />
                  <input type="hidden" id="email" value="{{safeEmail}}" />
                  <label for="password">Yeni şifre</label>
                  <input id="password" type="password" minlength="8" required autocomplete="new-password" />
                  <label for="confirm">Yeni şifre tekrar</label>
                  <input id="confirm" type="password" minlength="8" required autocomplete="new-password" />
                  <button type="submit" id="submit">Şifreyi güncelle</button>
                </form>
                <div id="message" class="message"></div>
              </main>
              <script>
                const form = document.getElementById('reset-form');
                const message = document.getElementById('message');
                const submit = document.getElementById('submit');

                form.addEventListener('submit', async (event) => {
                  event.preventDefault();
                  message.textContent = '';
                  message.className = 'message';

                  const token = document.getElementById('token').value.trim();
                  const email = document.getElementById('email').value.trim();
                  const password = document.getElementById('password').value;
                  const confirm = document.getElementById('confirm').value;

                  if (!token) {
                    message.textContent = 'Geçersiz sıfırlama bağlantısı.';
                    message.classList.add('error');
                    return;
                  }

                  if (password.length < 8) {
                    message.textContent = 'Şifre en az 8 karakter olmalıdır.';
                    message.classList.add('error');
                    return;
                  }

                  if (password !== confirm) {
                    message.textContent = 'Şifreler eşleşmiyor.';
                    message.classList.add('error');
                    return;
                  }

                  submit.disabled = true;

                  try {
                    const response = await fetch('/ResetPassword', {
                      method: 'POST',
                      headers: { 'Content-Type': 'application/json' },
                      body: JSON.stringify({
                        resetToken: token,
                        email: email || null,
                        newPassword: password
                      })
                    });

                    const payload = await response.json();
                    if (response.ok && payload.success) {
                      message.textContent = 'Şifreniz güncellendi. Cardence uygulamasına dönebilirsiniz.';
                      message.classList.add('success');
                      form.style.display = 'none';
                      return;
                    }

                    message.textContent = payload.message || 'Şifre güncellenemedi.';
                    message.classList.add('error');
                  } catch (_) {
                    message.textContent = 'Bağlantı hatası. Lütfen tekrar deneyin.';
                    message.classList.add('error');
                  } finally {
                    submit.disabled = false;
                  }
                });
              </script>
            </body>
            </html>
            """;

        return Content(html, "text/html; charset=utf-8");
    }
}
