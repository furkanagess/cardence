# 32 — App Store Screenshot 3: Etkinlik Grupları

**Pozisyon:** App Store'da 3. kare  
**Mesaj:** Konferans ve etkinlik kartlarını grupla.

**Boyut:** 1290×2796 (iPhone 6.7") veya 1320×2868  
**Kullanım:** Başına [00-global-design-system.md](./00-global-design-system.md) yapıştırın. Primary: `#0F5C6E`.

## Titles

| | Türkçe (TR store) | English (EN store) |
|---|-------------------|-------------------|
| **Title** | Konferans ve etkinlik sonrası<br>**kart karmaşasına son verin** | After every conference and meetup,<br>**end the card chaos** |
| **Subtitle** | Web Summit, SaaStr veya kendi etkinliğiniz — topladığınız tüm kartları gruplayın, detayda gözden geçirin ve ağ grafiğinde tek dokunuşla bulun. | Whether it's Web Summit, SaaStr, or your own meetup — group every card you collect, review them in detail, and find anyone in your network with one tap. |
| **Label** | Etkinlik Grupları | Event Groups |

---

## Stitch prompt

```
[GLOBAL DESIGN SYSTEM]

OUTPUT: App Store marketing screenshot — 1290×2796 portrait.

COMPOSITION:
1) MARKETING ZONE (top 30%):
   - Gradient band: #0F5C6E at 8% opacity fading to #F4F6F8
   - Headline (TR — use EN titles from Titles section for EN store):
     "Konferans ve etkinlik sonrası"
     second line bolder: "kart karmaşasına son verin"
   - Subhead:
     "Web Summit, SaaStr veya kendi etkinliğiniz — topladığınız tüm kartları gruplayın, detayda gözden geçirin ve ağ grafiğinde tek dokunuşla bulun."
   - Small event icon row (muted): calendar, location pin, groups

2) DEVICE — split composition showing depth:
   - Primary screen: Event Groups list (tab 1 active)
     - AppBar "Etkinlik grupları" + gear + "+"
     - 3 list cards:
       - "Web Summit 2026" — "18 kart"
       - "SaaStr Annual" — "9 kart"
       - "İstanbul Tech Meetup" — "6 kart"
     - Each row: event icon in primaryContainer circle, chevron
   - OPTIONAL: smaller overlapping phone/card (back-right) showing Event Group Detail:
     - Cover photo gradient header
     - Grid of mini contact avatars + card count chip

3) MARKETING CALLOUT (bottom third, above safe area):
   - Rounded panel white, 16px radius:
     - Title: "Etkinlik grupları"
     - Bullets with teal checkmarks:
       • "Kartları etkinliğe göre gruplayın"
       • "Detayda tüm bağlantıları görün"
       • "Ağ grafiğinde etkinlik ağını keşfedin"

MOOD: Conference professional, organized, post-event relief.
No stock photos of crowds. Turkish throughout.
```
