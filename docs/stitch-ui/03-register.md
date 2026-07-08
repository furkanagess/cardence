# 03 — Kayıt Ol (Register)

Yeni kullanıcı hesabı oluşturma ekranı. Login ile görsel aile uyumlu, bağımsız tam ekran auth deneyimi.

**Ürün bağlamı:** Ad, soyad, e-posta, şifre; opsiyonel telefon; kullanım koşulları onayı; LinkedIn ile kayıt alternatifi (login ile aynı sosyal satır).  
**Akış:** Kayıt sonrası → Onboarding (profil tamamlama) veya ana kabuk  
**İlgili:** [02-login.md](./02-login.md)

---

## Stitch prompt — Ana kayıt ekranı (önerilen)

```
[GLOBAL DESIGN SYSTEM — docs/stitch-ui/00-global-design-system.md]

Screen: Cardence Register — account creation (iOS/Android, Turkish UI, 390×844, light mode)

OVERALL MOOD:
Same premium B2B tone as Login — professional, minimal, high trust. User is investing identity data; form should feel structured and calm, not like a long bureaucratic wizard.

NO APP BAR with back chevron on first auth entry. If designing as push from Login, show subtle top-left back chevron (ghost, 40×40) floating over hero — optional second frame.

── LAYOUT STRUCTURE (top → bottom, scrollable) ──

1) COMPACT BRAND HEADER (top ~22% viewport):
- Same gradient family as Login: #F4F5F7 → #E8EEF5
- Centered, smaller than login hero:
  - Cardence wordmark only (no large animation) OR tiny connect icon 48px
  - 8px below: "Hesap oluşturun" — titleMedium semibold #1C2430
  - 4px below: "Dijital kartvizitinizi dakikalar içinde hazırlayın" — bodySmall #5A6578, centered, max 2 lines

2) FORM PANEL (white surface, top radius 24px, overlaps header by 16px):
- Padding: 24px horizontal, 24px top, 28px bottom
- Progress hint (optional, subtle): thin 3px track full width, navy fill 20% — signals "Adım 1 / Hesap" without heavy stepper UI

3) IDENTITY FIELDS (12px gap between field groups):

ROW A — Two columns (Ad | Soyad), equal width, 12px gutter:
- Left label "Ad *" — labelSmall #5A6578, red asterisk on required
- Input 48px height, person_outline icon, placeholder "Mehmet"
- Right label "Soyad *"
- Input placeholder "Yılmaz"

ROW B — Full width:
- Label "E-posta *"
- mail_outline icon, placeholder "ornek@email.com"

ROW C — Full width:
- Label row: "Telefon" left + muted pill badge right "Opsiyonel" (#E8EEF5 fill, navy text, 10px radius, 6px padding)
- Country chip 🇹🇷 +90 + national input, placeholder "5XX XXX XX XX"
- Helper microcopy below field (11px #8A94A6): "Etkinlik davetleri ve güvenlik için önerilir."

ROW D — Full width:
- Label "Şifre *"
- lock icon, visibility toggle
- Placeholder "En az 6 karakter"
- Password strength hint (optional, subtle): 4-dot meter, 1 dot filled navy = weak, 4 filled = strong — do not gamify with colors beyond navy/gray/green

4) LEGAL CONSENT (16px below password):
- Checkbox row, 44px min tap height:
  - Unchecked: 20px square, 1px #DDE2E9 border, 6px radius
  - Label rich text (bodySmall, #5A6578):
    "Kullanım Koşulları ve Gizlilik Politikası'nı okudum, kabul ediyorum."
  - "Kullanım Koşulları" and "Gizlilik Politikası" as tappable navy links inline
- Checked state: navy fill checkbox with white check

5) PRIMARY CTA (16px below legal):
- Full-width "Kayıt ol" — 52px height, navy #1B365D
- DISABLED state when checkbox unchecked: 40% opacity, no shadow

6) DIVIDER + SOCIAL (same pattern as Login):
- "veya" divider
- Outlined "LinkedIn ile devam et" button (identical styling to login screen for family consistency)

7) FOOTER:
- "Zaten hesabınız var mı? Giriş yap" — centered, secondary + primary link
- 16px safe area bottom padding

── STATES TO SHOW (pick 2 frames) ──

FRAME A — Default:
- Empty fields, checkbox unchecked, primary button disabled (muted)

FRAME B — Ready to submit:
- Sample data filled: Mehmet / Yılmaz / ayse@cardence.com / phone optional empty / password masked
- Checkbox checked
- Primary button full navy enabled

FRAME C — Validation error:
- Red border on "E-posta" field
- Helper: "Geçerli bir e-posta girin."
- Checkbox still checked; button enabled

FRAME D — Loading:
- Primary button spinner, all inputs disabled

── VISUAL RULES ──
- Required asterisk on labels only, not in placeholders
- No profile photo upload on this screen — that belongs to onboarding
- No business card preview yet — keep focus on account credentials
- Field labels always visible above inputs (not floating-only labels)
- Match Login form panel radius, button height, divider, and LinkedIn button exactly
- Turkish copy as specified; professional sentence case
```

---

## Stitch prompt — Kayıt (kompakt, klavye açık)

```
[GLOBAL DESIGN SYSTEM]

Screen: Cardence Register — keyboard-open scroll state (390×844)

Same register screen but:
- Brand header compressed to ~12% (wordmark hidden, only "Hesap oluşturun" + back chevron if present)
- Form scrolled so "Şifre" field and legal checkbox visible
- Primary CTA sticky above keyboard area (optional floating bar with top hairline)
- Demonstrates mobile ergonomics for long form
```

---

## Stitch prompt — Koyu tema varyantı

```
[GLOBAL DESIGN SYSTEM + DARK MODE VARIANT]

Screen: Cardence Register — dark mode

Mirror main Register prompt with dark tokens (same as Login dark variant):
- Header gradient #0F1419 → #1A2028
- Form panel #1A2028, inputs #28303A
- "Opsiyonel" badge: #28303A fill, #8FA8C4 text
- Links and primary CTA use #8FA8C4
- Legal text #A8B0BD, link accent #8FA8C4
```

---

## Login ↔ Register tutarlılık kontrol listesi

Stitch flow modunda iki ekranı üretirken aynı kalması gerekenler:

| Öğe | Login | Register |
|-----|-------|----------|
| Form panel üst radius | 24px | 24px |
| Yatay padding | 24px | 24px |
| Primary button yükseklik | 52px | 52px |
| Input yükseklik | 48px | 48px |
| Divider "veya" | ✓ | ✓ |
| LinkedIn butonu | ✓ | ✓ |
| Footer link pattern | Kayıt ol | Giriş yap |
| Hero gradient | ✓ | ✓ (daha kompakt) |

---

## Uygulama notları (Stitch dışı)

| Alan | Zorunlu | Not |
|------|---------|-----|
| Ad | Evet | Ayrı alan |
| Soyad | Evet | Ayrı alan |
| E-posta | Evet | |
| Şifre | Evet | Min. 6 karakter |
| Telefon | Hayır | Ülke kodu seçici |
| Kullanım koşulları | Evet | Checkbox olmadan submit kapalı |
