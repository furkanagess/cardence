# 21 — Profil / Kendi Kartlarım

Kullanıcının kendi dijital kartvizitlerini yönettiği sekme ve alt ekranlar.

| Bölüm | Dosya |
|-------|-------|
| Profil / Kartlarım | `lib/features/profile/presentation/pages/profile_page.dart` |
| Kartı düzenle | `lib/features/my_cards/presentation/pages/my_card_edit_page.dart` |
| Kart görünümü | `lib/features/my_cards/presentation/pages/card_view_page.dart` |
| Kart detay / paylaşım | `lib/features/my_cards/presentation/pages/card_detail_page.dart` |

**Sekme:** 2 — AppBar "Profil" + ⚙

```
Profil → Düzenle / Yeni kart → Kartı düzenle
      → Kart yüzü ve alan düzeni → Kart Görünümü
      → (Detay) Görünüm + Paylaşım
```

---

## Profil / Kartlarım

```
[GLOBAL DESIGN SYSTEM]

Screen: Profile — AppBar "Profil" + settings gear

Body:
- Section header: "Kartlarım" titleMedium semibold
- Horizontal card carousel (PageView):
  - Center card 88% viewport width, side cards peeking scaled down
  - FlippablePersonCard with user's own data
  - Dot indicators below carousel (navy active dot)
- Row under carousel: "Düzenle" text link aligned right
- Primary button full width: "Yeni kart" (+ icon)
- Tonal/secondary button: "Kart yüzü ve alan düzeni" → opens card view editor

Empty state (no cards):
- Empty card outline placeholder
- "İlk kartınızı oluşturun"
- Primary "Yeni kart"

Bottom nav tab 2 active.
```

---

## Kartı düzenle

```
[GLOBAL DESIGN SYSTEM]

Screen: My Card Edit — AppBar "Kartı düzenle" (or "Yeni kart") + "Kaydet" text action right

Top: Collapsible sticky card preview panel — FlippablePersonCard shrinks on scroll

Scroll sections:
1) "Kart adı" — field for internal label (e.g. "İş kartım")
2) "Kart bilgileri" — Ad Soyad, E-posta, Telefon (no char counter), Şirket, Pozisyon, Web, LinkedIn, Beceriler (chips), Okul, Hakkımda
3) "Tasarım" — color pickers for background + text color (chip grid)

Editor app bar. Form sections with titleSmall gray headers.
```

---

## Kart görünümü / alan düzeni

```
[GLOBAL DESIGN SYSTEM]

Screen: Card View / Layout Editor — AppBar "Kart Görünümü" + "Kaydet"

Layout:
- Card carousel top (same as profile, switch between user's cards)
- Section "Kart rengi" — color swatch grid + custom palette button
- Section "Metin rengi" — swatches + "Otomatik" chip
- Section "Ön yüzde göster" — toggle chips max 3: Pozisyon, E-posta, Telefon, Şirket...
- Section "Arka yüzde göster" — toggle chips max 3: E-posta, Telefon, Web, LinkedIn

Unsaved changes: back shows discard dialog.
```

---

## Kendi kart detay / paylaşım

```
[GLOBAL DESIGN SYSTEM]

Screen: Own Card Detail / Share — AppBar card name + Kaydet + edit icon

Top: Collapsible card preview

Sections:
1) "Görünüm" — "Kartı özelleştir" primary button (palette icon)
2) "Kartınızı paylaşın":
   - Card ID tile: badge icon + "Kart ID" label + 6-digit ID large spaced (e.g. 482917) + copy icon
   - If no ID yet: "Paylaşınca oluşturulur" placeholder
   - Primary: "Kartı paylaş" (share icon) — opens system share sheet
   - Tonal secondary: "QR ile paylaş"

Share is the hero action; ID must be visually prominent.
```

### Paylaşım metni örneği

```
Merhaba! Cardence kartımı seninle paylaşıyorum.

Kart: [Kart adı]
Kart ID: 482917

Cardence uygulamasında Kayıtlı Kartlar bölümünden "Kart ID ile ekle" ...
```

---

## Tüm akış (tek prompt — flow modu)

```
[GLOBAL DESIGN SYSTEM]

Design the Cardence "my cards / profile" flow (iOS/Android, Turkish UI).

Frame 1 — Profile tab (bottom nav tab 2):
- "Kartlarım" header, horizontal FlippablePersonCard carousel with dots
- "Düzenle", "Yeni kart", "Kart yüzü ve alan düzeni" actions

Frame 2 — Card edit "Kartı düzenle":
- Collapsible card preview on top
- Form sections: Kart adı, Kart bilgileri, Tasarım
- Editor AppBar with "Kaydet"

Frame 3 — Card layout "Kart Görünümü":
- Carousel + color pickers + front/back visible field toggle chips (max 3 each)

Frame 4 — Card detail / share:
- Card preview, "Kartı özelleştir", Card ID tile, "Kartı paylaş", "QR ile paylaş"

Keep consistent: same carousel (88% viewport), same FlippablePersonCard, navy primary CTAs.
```
