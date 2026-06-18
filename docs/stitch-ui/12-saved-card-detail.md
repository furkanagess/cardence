# 12 — Kayıtlı Kart Detay

**Dosya:** `lib/features/saved_cards/presentation/pages/saved_card_detail_page.dart`  
**Navigasyon:** Kayıtlı kartlar listesinden push

---

## Stitch prompt

```
[GLOBAL DESIGN SYSTEM]

Screen: Saved Card Detail — AppBar shows person display name (e.g. "Ayşe Yılmaz")

Scroll body:
1) Hero card preview — FlippablePersonCard OR physical photo card (front/back photo tabs if scanned)
2) Quick action row (if data exists): LinkedIn | E-posta | Telefon — icon chips in a row
3) Section "İletişim bilgileri":
   - Rows: icon in rounded square (primaryContainer bg) + label + value + copy icon
   - Fields: E-posta, Telefon, Web, LinkedIn, Şirket, Pozisyon etc.
4) Section "Etkinlik grupları":
   - Chips or list of linked group names + "Gruba ekle" tonal button
5) Section "Notlar":
   - Filled card with note text OR empty state "Not ekle" tappable
6) Footer meta: "Kaydedildi: 4 Haz 2026" small gray

Sticky bottom bar (above safe area):
- Full-width destructive button "Kartı sil" — red text/outline on white, not filled blood red

Manual-entry cards: small banner "Manuel giriş" subtle, no Cardence logo on card.
```
