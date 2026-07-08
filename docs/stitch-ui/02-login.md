# 02 — Giriş (Login)

Profesyonel dijital kartvizit cüzdanı için giriş ekranı. Mevcut uygulama hiyerarşisinden bağımsız, yeniden tasarlanmış auth deneyimi.

**Ürün bağlamı:** E-posta veya telefon + şifre ile giriş; LinkedIn ile hızlı giriş; kayıt ve şifre sıfırlama bağlantıları.  
**Akış:** Başarılı giriş → Onboarding veya ana kabuk  
**İlgili:** [03-register.md](./03-register.md) · [04-forgot-password.md](./04-forgot-password.md)

---

## Stitch prompt — Ana giriş ekranı (önerilen)

```
[GLOBAL DESIGN SYSTEM — docs/stitch-ui/00-global-design-system.md]

Screen: Cardence Login — premium B2B authentication (iOS/Android, Turkish UI, 390×844, light mode)

OVERALL MOOD:
Confident, calm, trustworthy — like signing into a professional networking tool (LinkedIn / Notion tone), not a playful consumer app. Clean whitespace, subtle brand presence, keyboard-friendly scroll.

NO APP BAR. Full-screen auth layout with safe area respected.

── LAYOUT STRUCTURE (top → bottom) ──

1) BRAND HERO ZONE (top ~32% viewport, non-scroll fixed feel):
- Background: soft vertical gradient #F4F5F7 → #E8EEF5
- Very faint Cardence watermark pattern at 4% opacity
- Centered brand moment:
  - Small animated-style illustration: two abstract business card shapes gently connecting with a soft navy pulse (reference splash "connect" motif, ~100px height)
  - 16px below: "Cardence" wordmark — titleLarge semibold #1C2430
  - 6px below: tagline "Share & Connect" — labelMedium #5A6578, letter-spacing +0.2
- Do NOT overcrowd hero; leave breathing room above form panel

2) FORM PANEL (white surface, top corners 24px radius, overlaps hero by 20px):
- Subtle top edge shadow OR 1px #DDE2E9 hairline only (prefer hairline)
- Inner padding: 24px horizontal, 28px top, 32px bottom
- Headline: "Cardence'e hoş geldiniz" — titleMedium semibold #1C2430, left-aligned
- Subhead: "Hesabınıza giriş yapın" — bodyMedium #5A6578, 4px below headline

3) METHOD SWITCHER (16px below subhead):
- Full-width segmented pill control, height 44px, radius 22px, #F0F2F6 track
- Two segments: "E-posta" | "Telefon"
- Selected segment: filled navy #1B365D, white semibold label
- Unselected: transparent, #5A6578 label
- Smooth pill indicator sliding between segments (visual only)

4) FORM FIELDS (16px below switcher, 12px vertical gap between fields):

EMAIL MODE (default selected):
- Field label above input: "E-posta" — labelSmall #5A6578
- Input: filled outlined style, 48px height, 10px radius, 1px #DDE2E9 border
  - Leading icon: mail_outline 20px #5A6578
  - Placeholder: "ornek@email.com"
  - Value example (optional in mock): "ayse@cardence.com"
- Field label: "Şifre"
- Password input: lock icon leading, trailing visibility toggle (eye icon)
  - Placeholder: "••••••••"
- Row below password (8px gap): left-aligned text link "Şifremi unuttum" — primary navy, 14px

PHONE MODE (alternate state — design as second frame OR show toggle):
- Field label: "Telefon numarası"
- Combined country selector + phone input in one row:
  - Left chip: 🇹🇷 +90 with chevron, 88px wide, same input height
  - Right: national number field, placeholder "5XX XXX XX XX"
- Field label: "Şifre" (same as email mode)
- Same "Şifremi unuttum" link

5) PRIMARY CTA (20px below last field):
- Full-width button "Giriş yap"
- Height 52px, radius 10px, navy fill #1B365D, white semibold label
- Subtle pressed state (5% darker)

6) DIVIDER ROW (20px below CTA):
- Horizontal hairline #DDE2E9 with centered capsule label "veya"
- Capsule: white fill, 1px border, 8px vertical / 14px horizontal padding, labelSmall #5A6578

7) SOCIAL SIGN-IN (16px below divider):
- Full-width outlined button, height 48px, white surface, 1px #DDE2E9 border
- Leading: LinkedIn "in" logo in official blue square (small, 20px)
- Label: "LinkedIn ile devam et" — bodyMedium #1C2430 semibold
- Not a loud social wall — single professional option only

8) FOOTER (24px below social, safe area bottom):
- Centered rich text: "Hesabınız yok mu? " (bodyMedium #5A6578) + "Kayıt ol" (primary navy semibold, tappable)
- Optional micro-trust line above footer (very subtle): shield icon + "Verileriniz güvenle saklanır" — 11px #8A94A6

── INTERACTION & STATES (show at least email mode + one error state) ──

DEFAULT: Email method selected, primary button enabled, fields empty or lightly prefilled.

LOADING: Primary button shows centered white spinner, fields disabled, 40% opacity on social button.

FIELD ERROR: Red helper under offending field (#B42318, 12px): "Geçerli bir e-posta girin." or "Şifre en az 6 karakter olmalıdır." Input border tint error red.

INLINE BANNER ERROR (optional, above form fields): soft red surface #FEF3F2, 1px #FECDCA border, 12px radius, 12px padding — "Giriş başarısız. Bilgilerinizi kontrol edin."

METHOD SWITCH: Show ghost text link under switcher as alternative affordance: "Telefon ile giriş yap" / "E-posta ile giriş yap" with phone/mail icon — only if segmented control feels cramped in Stitch output.

── VISUAL DETAILS ──
- Inputs use 16px horizontal inner padding; labels 4px above field
- Icons muted #5A6578, never pure black
- No heavy card-in-card nesting; one white form panel is enough
- Keyboard open: form scrolls; primary CTA remains visible above keyboard (sticky bottom optional)
- Avoid stock photos; brand illustration only in hero
- Turkish copy exactly as specified
```

---

## Stitch prompt — Telefon modu (ayrı kare)

```
[GLOBAL DESIGN SYSTEM]

Screen: Cardence Login — Phone method variant only (390×844, light)

Same layout as main Login prompt, but:
- Segmented control has "Telefon" selected (navy fill)
- Country code chip shows 🇹🇷 +90
- Phone field focused with blue/navy focus ring 2px
- Email fields hidden
- Rest unchanged: password, forgot link, Giriş yap, LinkedIn, Kayıt ol footer
```

---

## Stitch prompt — Koyu tema varyantı

```
[GLOBAL DESIGN SYSTEM + DARK MODE VARIANT from 00-global-design-system.md]

Screen: Cardence Login — dark mode

Same structure as main Login prompt with dark tokens:
- Hero gradient: #0F1419 → #1A2028
- Form panel surface: #1A2028, top radius 24px, outline #4A5568
- Headlines #ECEFF4, secondary #A8B0BD
- Inputs: #28303A fill, #4A5568 border, primary accent #8FA8C4 for links and selected segment
- Primary button: #8FA8C4 fill, #0F1419 label text
- LinkedIn button: #28303A surface, #4A5568 border
- Error colors unchanged for accessibility
```

---

## Uygulama notları (Stitch dışı)

| Özellik | Beklenen davranış |
|---------|-------------------|
| Giriş yöntemi | E-posta veya telefon + şifre |
| Sosyal | LinkedIn OAuth |
| Sonraki ekran | Kayıt → [03-register.md](./03-register.md); şifre → [04-forgot-password.md](./04-forgot-password.md) |
