# 18 — Etkinlik Grupları

Etkinlik grupları sekmesi, detay ekranı ve ilişkili sheet'ler.

| Bölüm | Dosya |
|-------|-------|
| Liste | `lib/features/event_groups/presentation/pages/event_groups_page.dart` |
| Detay | `lib/features/event_groups/presentation/pages/event_group_detail_page.dart` |
| Grup oluştur | `lib/features/event_groups/presentation/widgets/create_event_group_sheet.dart` |
| Gruba kart ekle | `lib/features/event_groups/presentation/widgets/pick_saved_cards_for_group_sheet.dart` |
| Karta grup bağla | `lib/features/event_groups/presentation/widgets/pick_event_groups_for_card_sheet.dart` |
| Grup adı diyaloğu | `lib/core/widgets/molecules/new_event_group_name_dialog.dart` |

**Sekme:** 1 — AppBar "Etkinlik grupları" + ⚙ + **+**

```
Etkinlik Grupları → [Detay] → Kayıtlı kart detay
                 → [+ Grup oluştur sheet] → Adım 1 ad | Adım 2 kart seç
                 → [Gruba kart ekle sheet]

Kayıtlı Kart Detay → [Gruba ekle sheet] → Etkinlik grubu seç
```

---

## Etkinlik grupları listesi

```
[GLOBAL DESIGN SYSTEM]

Screen: Event Groups List — AppBar "Etkinlik grupları" + settings gear + "+" icon (create group)

List:
- Each row: rounded card 10px radius, 1px border
  - Left: event icon in primaryContainer circle
  - Title: group name semibold
  - Subtitle: "12 kart" gray
  - Chevron right
- 16px vertical gap between rows

Empty state:
- event_note icon 64px muted
- "Henüz etkinlik grubu yok"
- "Networking etkinliklerinde topladığınız kartları gruplayın"
- Hint: "+" ile oluşturun

Bottom nav tab 1 active.
```

---

## Etkinlik grubu detay

```
[GLOBAL DESIGN SYSTEM]

Screen: Event Group Detail — AppBar group name (e.g. "Web Summit 2026")

AppBar action: person_add icon (add cards to group) when cards exist

Body scroll:
- Vertical list of FlippablePersonCard items (full width, 16px gap)
- Each card tappable → saved card detail
- Empty: "Bu grupta henüz kart yok" + "Kart ekle" button

Sticky bottom:
- Destructive "Bu grubu sil" bar (same pattern as saved card delete)
```

---

## Yeni etkinlik grubu oluştur (bottom sheet — 2 adım)

**Dosya:** `create_event_group_sheet.dart`

```
[GLOBAL DESIGN SYSTEM]

Screen: Create Event Group Sheet (isScrollControlled, ~88% height, drag handle)

Step 1 — "Yeni etkinlik grubu":
- Title titleLarge semibold
- Subtitle: grup adı açıklaması
- Field: Etkinlik adı (e.g. "Fuar 2026")
- Primary: "Devam" (validates non-empty, unique name)
- Error states: boş ad, duplicate name

Step 2 — "Kaydedilen kartlardan seç":
- Back to step 1
- Subtitle: "[Grup adı] grubuna eklenecek kayıtlı kartları seçin."
- Scrollable checklist: avatar + name + company + checkbox per saved card
- Primary: "Grubu oluştur" or "X kartla grubu oluştur" (disabled if no selection)
- Cards optional — can create empty group
```

---

## Gruba kart ekle (bottom sheet)

**Dosya:** `pick_saved_cards_for_group_sheet.dart`  
**Tetikleyici:** Grup detay AppBar person_add veya boş durum "Kart ekle"

```
[GLOBAL DESIGN SYSTEM]

Screen: Pick Saved Cards for Group Sheet (~75% height)

Title: "Kaydedilen kartlardan seç"
Subtitle: "[Grup adı] grubuna eklenecek kayıtlı kartları seçin."

Body: selectable saved card list (checkbox, avatar, name, company)
Bottom primary: "Kartları gruba ekle" or "X kartı gruba ekle" (disabled when none selected)
```

---

## Karta etkinlik grubu bağla (bottom sheet)

**Dosya:** `pick_event_groups_for_card_sheet.dart`  
**Tetikleyici:** Kayıtlı kart detay → "Gruba ekle"

```
[GLOBAL DESIGN SYSTEM]

Screen: Pick Event Groups for Card Sheet (~75% height)

Title: "Etkinlik grubu seç"
Subtitle: "[Kişi adı] kartının eklenebileceği grupları işaretleyin."

Body: CheckboxListTile per group name
Empty: "Henüz etkinlik grubu yok. Etkinlik grupları sekmesinden yeni grup oluşturabilirsiniz."
Bottom primary: "Gruplara ekle" or "X gruba ekle"
```

---

## Tüm akış (tek prompt — flow modu)

```
[GLOBAL DESIGN SYSTEM]

Design the Cardence event groups flow (iOS/Android, Turkish UI).

Frame 1 — Tab "Etkinlik grupları" (bottom nav tab 1 active):
- AppBar with + and settings
- List of group cards (icon, name, "N kart", chevron) OR empty state

Frame 2 — Group detail "Web Summit 2026":
- Vertical FlippablePersonCard list
- AppBar person_add action
- Sticky "Bu grubu sil" bottom bar

Frame 3 — Create group sheet step 1:
- "Yeni etkinlik grubu", name field, "Devam"

Frame 4 — Create group sheet step 2:
- "Kaydedilen kartlardan seç", checkbox list, "Grubu oluştur"

Frame 5 — Pick cards for group sheet:
- Same checklist pattern, "X kartı gruba ekle"

Frame 6 — Pick groups for card sheet (from saved card detail):
- Checkbox group names, "X gruba ekle"

Consistent: 16px sheet top radius, drag handle, navy primary buttons, 20px horizontal padding.
```
