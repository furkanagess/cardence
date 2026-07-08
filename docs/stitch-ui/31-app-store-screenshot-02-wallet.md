# 31 — App Store Screenshot 2: Cüzdan

**Pozisyon:** App Store'da 2. kare  
**Mesaj:** Networking sonrası kartları kaybetmeyin; dijital cüzdan.

**Boyut:** 1290×2796 (iPhone 6.7") veya 1320×2868  
**Kullanım:** Başına [00-global-design-system.md](./00-global-design-system.md) yapıştırın. Primary: `#0F5C6E`. **QR yok** — kart ekleme: fotoğraf/OCR, manuel, Kart ID.

## Titles

| | Türkçe (TR store) | English (EN store) |
|---|-------------------|-------------------|
| **Title** | **Tüm ağınız, tek cüzdanda** | **Your whole network, one wallet** |
| **Subtitle** | Fotoğraflayın, elle girin veya Kart ID ile ekleyin — hiçbir kart kaybolmasın. | Snap a photo, enter manually, or add by Card ID — never lose a card again. |
| **Label** | Dijital Cüzdan | Digital Wallet |

---

## Stitch prompt

```
[GLOBAL DESIGN SYSTEM]

OUTPUT: App Store marketing screenshot — 1290×2796 portrait.

COMPOSITION:
1) MARKETING HEADER (top 32%):
   - Background: clean #F5F7FB with subtle dot grid
   - Headline (TR — use EN title from Titles section for EN store):
     "Tüm ağınız, tek cüzdanda"
     - single line, bold accent on "tek cüzdanda" (#0F5C6E)
   - Subhead:
     "Fotoğraflayın, elle girin veya Kart ID ile ekleyin — hiçbir kart kaybolmasın."

2) DEVICE — Saved Cards tab (tab 0 active, NO app bar):
   - Wallet quota strip: "Cüzdan" + "24 / 50 kart" + navy progress bar ~48%
   - Toolbar: segmented "Kart" selected | "Liste" + filter icon
   - MAIN: Card stack view — 3 stacked FlippablePersonCards
     - Top card: "Mehmet Kaya" | "Acme Corp" | "CTO"
     - Behind cards scaled 96%/92%, soft shadow
   - FAB bottom-right: navy "+" circular button
   - Bottom nav tab 0 active

3) FLOATING ANNOTATION CARDS (outside phone, left and right — marketing only):
   - Left badge: photo_camera icon + "Kartvizit fotoğrafla"
   - Right badge: badge/id icon + "Kart ID ile ekle"
   - White cards, subtle shadow, connected to phone with thin dashed teal lines
   - OPTIONAL third small badge below: edit_note icon + "Elle gir" — do NOT show any QR scanner icon

4) BOTTOM STRIP:
   - Three micro-icons row: search | filter | stack — with labels "Ara" "Filtrele" "Görünüm"
   - Muted #5A6578

Avoid clutter. Emphasize "never lose a business card again" pain point.
Turkish UI + Turkish marketing copy.
```
