# 19 — Etkinlik Detay

Networking etkinliğinin tek ekran özeti: kapak, meta bilgiler, açıklama ve gruptaki kartlar.

**Navigasyon:** Etkinlik grupları listesinden push  
**İlgili akış:** [18-event-groups.md](./18-event-groups.md)

---

## Stitch prompt

```
[GLOBAL DESIGN SYSTEM — docs/stitch-ui/00-global-design-system.md]

Screen: Event Detail — immersive professional event hub (iOS/Android, Turkish UI, 390×844)

APP BAR (transparent over hero, becomes solid white on scroll):
- Back chevron left (white on hero → navy on scroll)
- Trailing: overflow menu (⋯) — Düzenle, Davet et, Sil
- No centered title on hero; title appears in collapsing header when scrolled

── HERO (top 220px) ──
- Full-bleed cover image OR soft navy gradient placeholder if no photo
- Bottom gradient scrim (transparent → 60% navy) for legibility
- Over scrim, left-aligned:
  - Status pill: "Devam ediyor" (green tint) | "Yaklaşan" (navy) | "Sona erdi" (gray)
  - Event title: "Web Summit 2026" — titleLarge bold white, max 2 lines
  - Meta row with small icons (white 90% opacity):
    - calendar: "15 Kas 2026 · 18:30"
    - location pin: "Lisbon, Portugal · Altice Arena"
- Optional: small circular avatar stack "+12" (linked cards count) bottom-right of hero

── SCROLL BODY (white surface, top radius 20px overlapping hero by 16px) ──

SECTION A — Quick stats (horizontal chip row, 12px gap, scroll if needed):
- Chip: people icon + "24 kart"
- Chip: mail icon + "3 davet"
- Chip: event icon + "Networking"

SECTION B — "Etkinlik hakkında" (if description exists):
- Section label: labelSmall uppercase tracking, muted gray
- Body text 2–4 lines, comfortable line-height; "Daha fazla göster" link if truncated
- If empty: omit section entirely (no placeholder box)

SECTION C — "Gruptaki kartlar" (primary content):
- Section header row:
  - Left: "Gruptaki kartlar" semibold
  - Right: tonal text button "+ Kart ekle"
- Horizontal card carousel (preferred) OR vertical stack:
  - Each item: compact FlippablePersonCard (~200px height) with 12px gap
  - Subtle 1px border, no heavy shadow
  - Name + company visible on card front
- Empty state (no cards yet):
  - Muted illustration area (dashed border, 120px height)
  - "Henüz kart eklenmedi"
  - "Kayıtlı kartlarınızdan seçin veya Card ID ile davet edin"
  - Primary tonal button: "Kart ekle"

SECTION D — "Davetler" (optional, if pending invites):
- Compact list rows: Card ID monospace + "Bekliyor" amber badge
- Swipe or icon to revoke invite

── STICKY BOTTOM ACTION BAR (safe area, white, top hairline border) ──
- Primary full-width: "Kart ekle" (navy) when cards exist
- OR split bar when event is editable:
  - Left outlined: "Düzenle"
  - Right primary: "Kart ekle"
- Destructive action NOT in sticky bar — only in overflow menu

VISUAL TONE:
- Premium B2B event app (Hopin / Luma meets digital wallet), not party flyer
- Generous whitespace, 20px horizontal padding
- One accent color (navy); status colors semantic only
- No tab bar on this screen (pushed route)

STATES TO SHOW (optional second frame):
1) Rich event — cover photo, description, 3+ cards in carousel
2) Minimal event — no photo, no description, empty cards with CTA
3) Ended event — gray status pill, muted hero, read-only (no "Kart ekle")
```

---

## Stitch prompt — Kompakt varyant (tek frame)

Liste detayından hızlı mockup için:

```
[GLOBAL DESIGN SYSTEM]

Screen: Event Detail — compact variant

AppBar: back + "Web Summit 2026" titleMedium semibold (solid, no hero)

Body scroll:
1) Cover thumbnail 16:9 rounded 12px (or placeholder with image icon)
2) Meta block:
   - "15 Kas 2026 · 18:30 – 21:00" with schedule icon
   - "Lisbon · Altice Arena" with pin icon
   - Badge row: "Yaklaşan" + "18 kart"
3) Description paragraph (gray body)
4) Section "Kartlar" — vertical FlippablePersonCard list, 16px gap
5) Outlined button full width: "Kart ekle"

No bottom nav. 20px padding. Flat, clean, corporate.
```

---

## Flow bağlamı (referans)

```
Etkinlik Grupları Listesi → [tap row] → Event Detail → [tap card] → Saved Card Detail
                                        → [Kart ekle] → Pick Saved Cards sheet
                                        → [⋯ Düzenle] → Edit Event sheet
```

---

## Üretim notları

- Önce **hero + scroll body** frame'ini üretin; sticky bar ikinci turda eklenebilir.
- Kart carousel için ISO 7810 oranını koruyun; yatay scroll snap hissi verin.
- Türkçe örnek metinler prompt'taki gibi kalsın; Stitch bazen İngilizce üretirse "Turkish UI copy" satırını tekrarlayın.
