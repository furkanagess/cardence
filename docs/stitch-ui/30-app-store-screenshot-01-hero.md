# 30 — App Store Screenshot 1: Dijital Kimliğiniz

**Pozisyon:** App Store'da 1. kare (en güçlü value prop)  
**Mesaj:** Profesyonel dijital kartvizit oluştur, Kart ID ile paylaş.

**Boyut:** 1290×2796 (iPhone 6.7") veya 1320×2868  
**Kullanım:** Başına [00-global-design-system.md](./00-global-design-system.md) yapıştırın. Primary: `#0F5C6E`. **QR yok** — paylaşım Kart ID + `Kartı paylaş`.

## Titles

| | Türkçe (TR store) | English (EN store) |
|---|-------------------|-------------------|
| **Title** | Dijital kartvizitiniz,<br>**her zaman yanınızda** | Your digital business card,<br>**always with you** |
| **Subtitle** | Profesyonel kimliğinizi oluşturun, benzersiz Kart ID'nizle anında paylaşın. | Build your professional identity and share instantly with your unique Card ID. |
| **Label** | Dijital Kimlik | Digital Identity |

---

## Stitch prompt

```
[GLOBAL DESIGN SYSTEM]

OUTPUT: App Store marketing screenshot — iPhone 6.7" portrait 1290×2796, NOT an in-app screen only.

COMPOSITION (top → bottom):
1) MARKETING BACKGROUND (top 38% of canvas):
   - Soft vertical gradient: #F4F6F8 → #E4EEF1 (very subtle teal tint toward bottom)
   - Faint Cardence watermark pattern at 3% opacity
   - Large headline (Turkish, left-aligned, 20px margin):
     "Dijital kartvizitiniz,"
     second line bolder: "her zaman yanınızda"
     - headlineLarge / bold 34–38px, color #1C2430
   - Subhead below (8px gap):
     "Profesyonel kimliğinizi oluşturun, benzersiz Kart ID'nizle anında paylaşın."
     - bodyLarge #5A6578, max 2 lines

2) DEVICE MOCKUP (center, slight 4° perspective optional but subtle):
   - Realistic iPhone 15 Pro frame, thin bezel, no notch exaggeration
   - Screen shows My Card Detail / share section (from Profile → card → detail):
     - AppBar back + card name "Ayşe Yılmaz"
     - FlippablePersonCard preview (teal gradient #0F5C6E)
     - Section "Kartınızı paylaşın":
       - Subtitle: "Kart ID'nizi gönderin; karşı taraf Cardence'te kartınızı ekleyebilir."
       - Card ID tile: "482917" + copy icon
       - Primary button: "Kartı paylaş" (share icon) — NO QR button, NO QR code on screen
     - Floating pill bottom nav partially visible

3) FEATURE CALLOUT PILLS (below device, 2 items horizontal):
   - Pill 1: badge/id icon + "Kart ID ile paylaş"
   - Pill 2: palette icon + "Markanıza özel tasarım"
   - Pills: white fill, 1px #DDE2E9 border, 12px radius, labelSmall semibold #0F5C6E

4) BRAND FOOTER (bottom safe area):
   - Small Cardence wordmark + tagline "Share & Connect" in labelSmall #8A94A6

MOOD: Confident professional, premium but approachable. No people photos. UI must look production-ready.
Language in UI: Turkish. Marketing text: Turkish.
```
