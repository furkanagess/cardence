# 04 — Şifremi Unuttum

**Dosya:** `lib/features/auth/presentation/pages/forgot_password_page.dart`  
**Navigasyon:** Login'den push

---

## Stitch prompt

```
[GLOBAL DESIGN SYSTEM]

Screen: Cardence Forgot Password — AppBar "Şifremi unuttum"

Multi-step feel in single scroll page OR 2 visual states:

State A — Request OTP:
- Illustration-free; icon circle with mail_outline in primaryContainer
- Title: "E-posta adresinizi girin"
- Body: "Size doğrulama kodu göndereceğiz"
- Email field
- Primary: "Kod gönder"

State B — Reset:
- OTP field (6 digit boxes or single field)
- New password + confirm password fields
- Primary: "Şifreyi güncelle"

Minimal, security-focused, no distractions.
```
