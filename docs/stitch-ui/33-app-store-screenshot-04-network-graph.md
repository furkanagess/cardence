# 33 — App Store Screenshot 4: Ağ Grafiği

**Pozisyon:** App Store'da 4. kare (differentiator)  
**Mesaj:** Kartlar, şirketler ve etkinlikler arası bağlantıları görselleştirin.

**Boyut:** 1290×2796 (iPhone 6.7") veya 1320×2868  
**Kullanım:** Başına [00-global-design-system.md](./00-global-design-system.md) yapıştırın. Primary: `#0F5C6E`.

## Titles

| | Türkçe (TR store) | English (EN store) |
|---|-------------------|-------------------|
| **Title** | Profesyonel ağınızı<br>**harita gibi görün** | See your professional network<br>**as a living map** |
| **Subtitle** | Kartlarınız, şirketleriniz ve katıldığınız etkinlikler arasındaki bağlantıları keşfedin; iki kişi arasındaki en kısa yolu görsel olarak takip edin. | Explore how your cards, companies, and events connect — then trace the shortest path between any two people in your network visually. |
| **Label** | Ağ Grafiği | Network Graph |

---

## Stitch prompt

```
[GLOBAL DESIGN SYSTEM]

OUTPUT: App Store marketing screenshot — 1290×2796 portrait.

COMPOSITION:
1) MARKETING HEADER (top 28%):
   - Dark-to-light diagonal gradient: #0F1419 (top-left corner accent only) → #F4F6F8
   - Headline (TR — use EN titles from Titles section for EN store):
     "Profesyonel ağınızı"
     second line bolder: "harita gibi görün"
   - Subhead:
     "Kartlarınız, şirketleriniz ve katıldığınız etkinlikler arasındaki bağlantıları keşfedin; iki kişi arasındaki en kısa yolu görsel olarak takip edin."
   - Teal accent underline beneath "harita gibi görün"

2) DEVICE — Network Graph full screen:
   - AppBar "Ağ Grafiği" + analytics icon
   - Canvas background #F4F6F8 with subtle grid
   - Legend top-left pills: Ben | Bağlantı | Şirket | Etkinlik
   - Radial graph layout:
     - Center: user's own card node (avatar circle, slightly larger)
     - Ring 1: 4–5 person card nodes with small labels
     - Ring 2: 2 company nodes (rounded square, business icon)
     - Ring 3: 1 event node (diamond/rotated square, event icon)
     - Curved edges in teal/navy/green — not spaghetti, readable
   - Bottom detail panel partially visible:
     - "Bağlı düğümler (4)" with one contact row

3) SIDE ANNOTATIONS (marketing graphics outside phone):
   - Arrow + label "Şirket düğümleri"
   - Arrow + label "Etkinlik bağlantıları"
   - Arrow + label "En kısa yol"

4) FOOTER BADGE:
   - "Cardence Network Graph" pill — premium feature feel, not gamified

This screenshot must communicate intelligence and relationship mapping — Cardence's unique moat vs generic contact apps.
Turkish UI labels. Clean, not cluttered.
```
