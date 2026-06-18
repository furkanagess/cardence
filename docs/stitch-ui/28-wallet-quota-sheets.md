# 28 — Cüzdan Kotası / Yükseltme (Bottom Sheet)

**Dosya:**
- `lib/features/saved_cards/presentation/widgets/wallet_quota_detail_sheet.dart`
- `lib/features/saved_cards/presentation/widgets/wallet_upgrade_sheet.dart`

**Tetikleyici:** Kayıtlı kartlar cüzdan şeridine dokunma

---

## Stitch prompt — Kota detay

```
[GLOBAL DESIGN SYSTEM]

Screen: Wallet Quota Detail Sheet

Quota detail:
- Title "Cüzdan kotası"
- Large numbers: "12 / 50 kart"
- Progress ring or bar
- Plan name "Ücretsiz" badge
- Button "Paketi yükselt"
```

## Stitch prompt — Paket yükseltme

```
[GLOBAL DESIGN SYSTEM]

Screen: Wallet Upgrade Sheet

Upgrade sheet:
- 2-3 plan cards side by side or stacked
- Free / Pro / Business with card limits
- Selected plan navy border
- Primary "Yükselt"
```

## İlgili bileşen

- `saved_cards_wallet_strip.dart` — Ana ekrandaki kota şeridi
