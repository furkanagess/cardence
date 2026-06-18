# 05 — Onboarding (5 Adım)

**Dosya:** `lib/features/onboarding/presentation/pages/onboarding_page.dart`  
**Widget'lar:** `lib/features/onboarding/presentation/widgets/onboarding_step_*.dart`  
**Navigasyon:** Login sonrası → tamamlanınca Main Shell

---

## Ortak chrome (tüm adımlar)

```
[GLOBAL DESIGN SYSTEM]

Onboarding wizard chrome (applies to all 5 steps):
- NO app bar
- Fixed bottom bar: 5 step dots (active step filled navy, rest gray) + full-width primary button
- System back gesture = previous step (hidden on step 1)
- PageView, non-scrollable between steps
- Progress feel: wizard, not settings page
- Generous top padding, form centered in upper 60% (except step 5)
```

---

## Adım 1 / 5 — Adınız

**Dosya:** `onboarding_step_name.dart`

```
[GLOBAL DESIGN SYSTEM + Onboarding wizard chrome]

Screen: Onboarding Step 1/5 — "Adınız"

Content:
- Step title large: "Adınız"
- Subtitle: "Kartınızda görünecek adınızı girin"
- Fields: Ad* | Soyad* (filled outlined, 10px radius)

Bottom bar: dot 1 active, button "Devam"
```

---

## Adım 2 / 5 — İş bilgileri

**Dosya:** `onboarding_step_professional.dart`

```
[GLOBAL DESIGN SYSTEM + Onboarding wizard chrome]

Screen: Onboarding Step 2/5 — "İş bilgileri"

Content:
- Step title: "İş bilgileri"
- Subtitle: "Kartınızın ön yüzünde görünecek bilgiler"
- Fields: Şirket* (business icon) | Pozisyon* (work icon)

Bottom bar: dot 2 active, button "Devam"
```

---

## Adım 3 / 5 — E-posta

**Dosya:** `onboarding_step_contact.dart`

```
[GLOBAL DESIGN SYSTEM + Onboarding wizard chrome]

Screen: Onboarding Step 3/5 — "E-posta"

Content:
- Step title: "E-posta"
- Subtitle: "İletişim için e-posta adresiniz"
- Fields: E-posta* (required)

Bottom bar: dot 3 active, button "Devam"
```

---

## Adım 4 / 5 — Ek bilgiler (opsiyonel)

**Dosya:** `onboarding_step_optional.dart`

```
[GLOBAL DESIGN SYSTEM + Onboarding wizard chrome]

Screen: Onboarding Step 4/5 — "Ek bilgiler"

Content:
- Step title: "Ek bilgiler"
- Badge chip next to title: "Opsiyonel" (tonal, small, rounded)
- Subtitle: "İsterseniz şimdi ekleyin, sonra da düzenleyebilirsiniz"
- Fields (scrollable):
  - Telefon (country picker, no character counter)
  - Web sitesi
  - LinkedIn
  - Okul
  - Hakkımda (multiline, max 200)
  - Beceriler (chip input area)

Bottom bar: dot 4 active, button "Devam"
```

---

## Adım 5 / 5 — Kart önizlemesi

**Dosya:** `onboarding_step_preview.dart`

```
[GLOBAL DESIGN SYSTEM + Onboarding wizard chrome]

Screen: Onboarding Step 5/5 — "Kart önizlemesi"

Content:
- Step title: "Kart önizlemesi"
- Hero: Live FlippablePersonCard preview centered with entered data (name, company, email etc.)
- Tap hint: small text "Kartı çevirmek için dokunun"
- Section "Kart rengi": horizontal row of color circles (navy default + 5-6 presets + palette icon)
- Section "Metin rengi": similar row with "Otomatik" default chip

Bottom bar: dot 5 active, button "Kartımı oluştur" (primary, celebratory but still corporate)
```

---

## Tüm akış (tek prompt — flow modu)

Stitch flow modunda tüm onboarding'i tek seferde üretmek için:

```
[GLOBAL DESIGN SYSTEM]

Design a 5-step onboarding wizard flow for Cardence (iOS/Android).

Shared chrome across all steps:
- No app bar
- Fixed bottom: 5 progress dots + full-width primary CTA
- Back = previous step (step 1 has no back)
- Turkish copy, corporate navy theme

Step 1 "Adınız": Ad*, Soyad* fields. CTA "Devam"
Step 2 "İş bilgileri": Şirket*, Pozisyon*. CTA "Devam"
Step 3 "E-posta": E-posta*. CTA "Devam"
Step 4 "Ek bilgiler" (Opsiyonel badge): Telefon, Web, LinkedIn, Okul, Hakkımda, Beceriler. CTA "Devam"
Step 5 "Kart önizlemesi": FlippablePersonCard live preview, color pickers for card/text. CTA "Kartımı oluştur"

Keep visual consistency: same spacing, typography, and bottom bar across all 5 frames.
```
