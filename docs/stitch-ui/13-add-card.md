# 13 — Kart Ekleme Akışı

Kayıtlı kartlara yeni kart ekleme: bottom sheet seçici + üç alt ekran.

| Bölüm | Dosya |
|-------|-------|
| Seçici sheet | `lib/features/saved_cards/presentation/widgets/add_saved_card_sheet.dart` |
| Manuel giriş | `lib/features/saved_cards/presentation/pages/add_manual_card_page.dart` |
| Kart ID | `lib/features/saved_cards/presentation/pages/add_card_by_id_page.dart` |
| Fotoğraf / OCR | `lib/features/saved_cards/presentation/pages/scan_physical_card_page.dart` |

**Tetikleyici:** Kayıtlı kartlar FAB veya "Kart ekle"

```
Kayıtlı Kartlar → [Kart ekle sheet] → Manuel | Fotoğrafla | Kart ID
```

---

## Kart ekle (bottom sheet)

```
[GLOBAL DESIGN SYSTEM]

Screen: Bottom Sheet — "Kart ekle"

Sheet: 16px top radius, drag handle, white surface
Title: "Kart ekle" titleLarge
Subtitle: "38 kart daha ekleyebilirsiniz." (or quota full warning in warning color)

3 method tiles (full width, 12px radius, surfaceVariant bg, 16px padding each):
1) edit_note icon | "Bilgileri elle gir" | subtitle gray
2) photo_camera icon | "Kartvizit fotoğrafla" | subtitle about OCR
3) badge icon | "Kart ID ile ekle" | subtitle about Cardence users

Each tile: leading icon in navy circle, title semibold, subtitle 2 lines max, chevron right.
Disabled state when wallet full: grayed + lock icon.
```

---

## Manuel kart ekle

```
[GLOBAL DESIGN SYSTEM]

Screen: Manual Card Add — AppBar "Manuel kart ekle"

Scroll form:
- Intro text gray: "Kartvizitteki bilgileri girin"
- Fields: Ad Soyad*, Şirket, Pozisyon, E-posta, Telefon (country picker, no counter), Web, LinkedIn, Not (optional)
- Primary bottom-fixed or end-of-list: "Kartı kaydet"

Editor app bar variant. Clean form, no card preview required (optional small preview at top).
```

---

## Kart ID ile ekle

```
[GLOBAL DESIGN SYSTEM]

Screen: Add Card by ID — AppBar "Kart ID ile ekle"

Content:
- Body text: "Paylaşılan kart kimliğini girin. Bilgiler sunucudaki güncel kartvizitten alınır."
- Single prominent field: "Kart ID" with badge icon, 6-digit numeric placeholder "482917"
- Primary: "Kartı ekle"

Minimal single-purpose screen. Validation hint under field.
```

---

## Kartvizit fotoğrafla (OCR)

```
[GLOBAL DESIGN SYSTEM]

Screen: Scan Physical Card — AppBar "Kartvizit fotoğrafla"

Layout:
- Section "Ön yüz" (required): dashed border drop zone 16:10 ratio OR captured photo thumbnail with retake button
- Section "Arka yüz" (optional): same pattern, labeled "Opsiyonel"
- Tip card: info icon + "Fotoğraf net ve düz olmalı"
- Primary: "Bilgileri oku" (disabled until front photo)
- Loading state: shimmer over fields

Camera/gallery picker buttons inside drop zones.
```

---

## Tüm akış (tek prompt — flow modu)

Stitch flow modunda kart ekleme akışını tek seferde üretmek için:

```
[GLOBAL DESIGN SYSTEM]

Design the Cardence "add saved card" flow (iOS/Android, Turkish UI).

Frame 1 — Bottom sheet "Kart ekle":
- Quota subtitle, 3 method tiles: Manuel giriş | Fotoğrafla | Kart ID
- Navy icon circles, chevrons, 16px top sheet radius

Frame 2a — "Manuel kart ekle" (AppBar + back):
- Form: Ad Soyad*, Şirket, Pozisyon, E-posta, Telefon, Web, LinkedIn, Not
- Primary "Kartı kaydet"

Frame 2b — "Kart ID ile ekle":
- Short intro, single 6-digit Kart ID field, "Kartı ekle" button

Frame 2c — "Kartvizit fotoğrafla":
- Ön yüz drop zone (required), Arka yüz (optional), tip card, "Bilgileri oku"

Keep consistent: same navy primary, 10px input radius, editor AppBar on sub-screens.
```
