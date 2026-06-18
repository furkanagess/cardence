# Global Design System — Stitch Prompt

> **Kullanım:** Bu bloğu her ekran prompt'unun **başına** yapıştırın.

```
Design a mobile app screen for "Cardence" — a professional digital business card wallet app (iOS/Android, 390×844).

DESIGN LANGUAGE:
- Material 3 inspired, corporate-calm, minimal elevation
- Primary navy: #1B365D | Background: #F4F5F7 | Surface/cards: #FFFFFF
- Secondary text: #5A6578 | Borders: #DDE2E9 (1px hairline)
- Semantic: success #1F6B4F, error #B42318, warning #B54708
- Border radius: 10px inputs/buttons/cards, 12px dialogs, 16px top on bottom sheets
- No heavy shadows; flat cards with subtle 1px outline
- Typography: system sans (SF Pro / Roboto), Turkish UI copy
- Headlines: semibold 600, body line-height ~1.45
- Faint watermark pattern in background (subtle brand mark, very low opacity)

SIGNATURE COMPONENT — Flippable Business Card:
- ISO 7810 credit card ratio (1.586:1), height ~232px
- Rounded corners 12px, optional custom background color
- Front: person name (large), company (secondary), up to 3 contact fields with icons
- Back: notes or extra fields, flip icon top-right
- Optional small Cardence logo corner badge on Cardence-linked cards

BOTTOM NAV (main shell only):
- Floating pill bar, height 56px, radius 28px, centered above safe area
- 3 icon-only tabs: people (saved cards), event_note (groups), person (profile)
- Active tab: navy sliding indicator behind icon, icon 22px; inactive 18px muted gray
- No labels under icons

APP BAR VARIANTS:
- Root: centered title, settings gear icon right
- Flow: back arrow left, title left-aligned
- Editor: back + title left, text action "Kaydet" right

All screens use generous 20px horizontal padding unless noted.
Language: Turkish.
Style: premium B2B networking app, not playful consumer social.
```

## Dark mode (ikinci tur)

Aynı global bloğa şunu ekleyin:

```
DARK MODE VARIANT:
- Background: #0F1419 | Surface: #1A2028 | Surface variant: #28303A
- Primary: #8FA8C4 | Text primary: #ECEFF4 | Text secondary: #A8B0BD
- Outline: #4A5568
```

## Kod referansları

| Token | Dosya |
|-------|-------|
| Renkler | `lib/core/theme/app_colors.dart` |
| Tema | `lib/core/theme/app_theme.dart` |
| Kart bileşeni | `lib/core/widgets/organisms/flippable_person_card.dart` |
| AppBar | `lib/core/widgets/atoms/cardence_app_bar.dart` |
