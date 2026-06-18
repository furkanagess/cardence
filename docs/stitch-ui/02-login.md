# 02 — Giriş (Login)

**Dosya:** `lib/features/auth/presentation/pages/login_page.dart`  
**Navigasyon:** Başarılı giriş → Onboarding veya Main Shell

---

## Stitch prompt

```
[GLOBAL DESIGN SYSTEM]

Screen: Cardence Login — "Hesabınıza giriş yapın"

Layout (scrollable, safe area):
- Top: same connect animation (smaller, ~120px) + "Cardence" wordmark
- Subtitle: "Hesabınıza giriş yapın" bodyLarge #5A6578, centered
- Segmented control (pill toggle): "E-posta" | "Telefon" — selected segment filled navy, white text
- Form (email mode):
  - Filled outlined field: E-posta (envelope icon)
  - Filled outlined field: Şifre (lock icon, visibility toggle)
- Primary full-width button: "Giriş yap" navy filled, 48px height, 10px radius
- Text link row: "Şifremi unuttum" left-aligned, primary color
- Divider with "veya" centered
- Bottom text: "Hesabınız yok mu? Kayıt ol" — "Kayıt ol" is tappable link in primary

Phone mode variant: country code picker + phone field instead of email.

No app bar. Keyboard-friendly spacing. Error state: red helper text under field.
```
