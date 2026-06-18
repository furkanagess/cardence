# 11 — Kayıtlı Kartlar (Ana Sekme)

**Dosya:** `lib/features/saved_cards/presentation/pages/saved_cards_page.dart`  
**Sekme:** 0 — AppBar yok

---

## Stitch prompt

```
[GLOBAL DESIGN SYSTEM]

Screen: Cardence Saved Cards — main wallet tab (NO app bar title)

Top to bottom:
1) WALLET QUOTA STRIP — full width card:
   - Row: wallet icon + "Cüzdan" label + "12 / 50 kart" right
   - Progress bar below (navy fill, turns orange/red near limit)
   - Tappable entire strip

2) TOOLBAR ROW:
   - Left: segmented control "Kart" | "Liste" (Kart selected)
   - Right: filter icon button with red dot badge if filters active

3) MAIN CONTENT — Card Stack View (Kart mode):
   - 3-4 stacked business cards offset vertically (deck effect)
   - Top card fully visible: FlippablePersonCard with real contact data
   - Cards behind scaled 96%/92%, slight Y offset
   - Tap top card → detail

4) DRAGGABLE FAB bottom-right:
   - Circular navy button with "+" icon, subtle shadow
   - Can sit above bottom nav

Empty state variant:
- Large muted contacts icon 64px
- "Henüz kart yok"
- "Kartvizit fotoğraflayın veya manuel ekleyin"
- Secondary button "Kart ekle"

Liste mode variant: compact list tiles with avatar circle, name, company, chevron.

Bottom nav visible, tab 0 active. No top app bar.
```
