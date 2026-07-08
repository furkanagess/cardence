# 34 — App Store Screenshot 5: Kart Detay

**Pozisyon:** App Store'da 5. kare (conversion / utility)  
**Mesaj:** Kayıtlı kart detayı, hızlı iletişim, notlar, etkinlik bağlantısı.

**Boyut:** 1290×2796 (iPhone 6.7") veya 1320×2868  
**Kullanım:** Başına [00-global-design-system.md](./00-global-design-system.md) yapıştırın. Primary: `#0F5C6E`.

## Titles

| | Türkçe (TR store) | English (EN store) |
|---|-------------------|-------------------|
| **Title** | Kayıtlı kartlarınızdan<br>**bir dokunuşla iletişime geçin** | From any saved card,<br>**reach out in one tap** |
| **Subtitle** | E-posta, telefon, LinkedIn ve web sitesine anında ulaşın; kişisel notlarınızı ekleyin ve hangi etkinlikte tanıştığınızı tek ekranda takip edin. | Jump to email, phone, LinkedIn, or website instantly — add personal notes and see where you met, all on a single relationship-focused screen. |
| **Label** | Kart Detayı | Card Detail |

---

## Stitch prompt

```
[GLOBAL DESIGN SYSTEM]

OUTPUT: App Store marketing screenshot — 1290×2796 portrait.

COMPOSITION:
1) MARKETING HEADER (top 26%):
   - Background #F5F7FB
   - Headline (TR — use EN titles from Titles section for EN store):
     "Kayıtlı kartlarınızdan"
     second line bolder: "bir dokunuşla iletişime geçin"
   - Subhead:
     "E-posta, telefon, LinkedIn ve web sitesine anında ulaşın; kişisel notlarınızı ekleyin ve hangi etkinlikte tanıştığınızı tek ekranda takip edin."

2) DEVICE — Saved Card Detail (full scroll snapshot composited):
   - NO traditional app bar — overlay back/edit on gradient hero (like production app)
   - Hero: gradient banner #0F5C6E + left avatar + copyable card ID pill "A4B2C9"
   - Name: "Elif Demir" | "VP Sales • Nordex"
   - Location pill: "İstanbul, Türkiye"
   - Action bar: outlined chips E-posta | Telefon | LinkedIn | Web sitesi
   - Section "Kart görünümü": small FlippablePersonCard preview
   - Section "İletişim bilgileri": grouped rows with copy icons
   - Section "Katıldığı etkinlikler": chips "Web Summit 2026" + "Gruba ekle"
   - Section "Özel notlar": quoted note in accent panel with teal left border

3) MARKETING HIGHLIGHTS (3 floating tags pointing to UI areas):
   - "Kopyala & paylaş" → card ID area
   - "Kişisel not" → notes section
   - "Etkinlik bağlantısı" → event chips

4) TRUST LINE (bottom):
   - Shield icon + "Verileriniz güvenle saklanır" — 11px #8A94A6

MOOD: CRM-light, personal, actionable. Shows Cardence is not just a card — it's a relationship tool.
Turkish copy only. Premium B2B aesthetic.
```
