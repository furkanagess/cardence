# 29 — Premium Paywall (Tam Ekran)

**Hedef:** RevenueCat `premium_wallet` aboneliği için tam ekran paywall  
**Mevcut referans:** `lib/features/saved_cards/presentation/widgets/wallet_upgrade_sheet.dart` (bottom sheet — bu prompt daha zengin tam ekran alternatif)  
**Tetikleyiciler:** Cüzdan limiti, manuel/fotoğraf hakkı bitti, çoklu kendi kartı, upgrade CTA

---

## Stitch prompt — Ana paywall (önerilen)

```
[GLOBAL DESIGN SYSTEM]

Screen: Cardence Premium Paywall — full-screen modal, 390×844, light mode

OVERALL MOOD:
Premium B2B networking app. Confident, calm, trustworthy — not gamified, not neon, not consumer-social. Feels like upgrading a professional tool (LinkedIn Premium / Notion Pro tone), not a mobile game.

LAYOUT STRUCTURE (top → bottom, scrollable if needed):

1) HEADER ROW (20px horizontal padding, safe area top):
- Left: circular ghost close button (X), 40×40, subtle #DDE2E9 outline
- Center: small pill badge "Cardence Premium" with workspace_premium icon, navy text on #E8EEF5 fill
- Right: empty spacer for balance

2) HERO SECTION (centered, 24px top spacing):
- Decorative soft radial glow behind hero (navy #1B365D at 8% opacity, blurred)
- Hero visual: stacked mini business cards (2 cards, ISO 7810 ratio, 12px radius)
  - Front card: sample name "Ayşe Yılmaz", company "Cardence", navy accent strip left edge
  - Back card: offset 12px down-right, lighter surface, subtle outline
  - Small floating badge on front card corner: "∞" or infinity icon in success green circle — signals unlimited wallet
- Headline (titleLarge, semibold, centered, max 2 lines):
  "Profesyonel ağınızı sınırsız büyütün"
- Subtitle (bodyMedium, #5A6578, centered, max 3 lines):
  "Daha fazla kartvizit saklayın, kendi kartlarınızı çoğaltın ve etkinliklerinizi tek yerden yönetin."

3) FREE vs PREMIUM COMPARISON CARD (full width, 20px padding):
- White surface, 12px radius, 1px #DDE2E9 border, 16px inner padding
- Two-column header row: "Ücretsiz" (muted) | "Premium" (navy semibold + small check badge)
- 5 comparison rows, each row 44px min height, hairline divider between rows:
  | Feature | Free | Premium |
  | Kayıtlı kart cüzdanı | 15 kart | Sınırsız |
  | Kendi kartlarım | 1 kart | 50 karta kadar |
  | Elle / fotoğrafla ekleme | 1 deneme | Sınırsız |
  | Etkinlik grupları | Sınırlı | Sınırsız |
  | Reklamsız deneyim | — | ✓ |
- Free column values: secondary gray text
- Premium column values: navy semibold or green check icon (#1F6B4F)
- Use compact table-like layout, not heavy grid borders

4) BENEFIT CHIPS ROW (horizontal scroll optional, or 2×2 grid):
Four compact benefit tiles (surfaceVariant bg #F4F5F7, 10px radius, 12px padding):
- credit_card icon | "Sınırsız cüzdan"
- edit_note icon | "Elle & fotoğraf"
- event icon | "Etkinlik grupları"
- block icon | "Reklamsız"

5) PLAN SELECTOR (single plan — monthly):
- One selected plan card, full width, navy 2px border, soft #E8EEF5 fill
- Left: radio selected (navy filled)
- Center stack:
  - Title: "Aylık Premium"
  - Subtitle: "İstediğiniz zaman iptal edin"
- Right aligned price block:
  - Large price: "₺149,99"
  - Small caption below: "/ ay"
- Optional secondary ghost row below (unselected style, lighter):
  "Yıllık plan — yakında" disabled gray, 40% opacity (placeholder for future)

6) PRIMARY CTA (sticky feel at bottom section, 20px padding):
- Full-width button, 52px height, 12px radius, navy #1B365D fill, white text semibold:
  "Premium'a geç"
- Micro trust line under button (labelSmall, #5A6578, centered):
  "App Store / Google Play üzerinden güvenli ödeme"

7) FOOTER LINKS (centered, 12px spacing):
- Text button: "Satın alımları geri yükle" (primary navy, no underline)
- Legal row (labelSmall, #5A6578):
  "Kullanım Koşulları · Gizlilik Politikası" — tappable links

STATES TO SHOW (optional second frame or annotated variants):
A) Default — all benefits visible, monthly plan selected
B) Context banner under hero (warning tint #FFF4E5, warning text #B54708):
   "Ücretsiz elle ekleme hakkınız doldu" — when triggered from manual/photo limit
C) Context banner variant:
   "Cüzdan limitinize ulaştınız (15/15)" — when triggered from wallet quota
D) Loading overlay on CTA: spinner + "İşleniyor…"
E) Success toast/snackbar: green "Premium aktif — keyfinize bakın"

DO NOT:
- No confetti, no trophy emojis, no gradient purple/pink startup aesthetic
- No fake countdown timers or "50% OFF TODAY ONLY"
- No more than one primary CTA
- No English UI copy (Turkish only)
- No bottom tab bar on this screen

ACCESSIBILITY:
- Tap targets min 44px
- Contrast AA on all text
- Close button reachable with one thumb (top-left)
```

---

## Stitch prompt — Kompakt bottom sheet (mevcut akışa yakın)

Mevcut `WalletUpgradeSheet` yerine daha cilalı sheet versiyonu:

```
[GLOBAL DESIGN SYSTEM]

Screen: Cardence Premium Upgrade — bottom sheet, isScrollControlled, 16px top radius, drag handle

Sheet content (20px padding):
- Row: workspace_premium icon in navy circle 44px + column:
  - Title "Premium cüzdan" titleLarge semibold
  - Subtitle bodyMedium gray: "Ağınızı ölçeklendirmek için bir adım"
- Divider hairline
- Benefit list (4 rows, icon 22px navy + bodyMedium text, 10px vertical gap):
  1. Sınırsız kart kaydı
  2. 50 karta kadar kendi kartınız
  3. Sınırsız elle ve fotoğrafla ekleme
  4. Reklamsız deneyim
- Compact price pill centered: "₺149,99 / ay"
- Primary button full width: "Premium'a geç"
- TextButton: "Satın alımları geri yükle"
- Caption centered labelSmall gray: "App Store / Play Store üzerinden güvenli ödeme."

Sheet max height ~75% screen; background dimmed scrim 40% black behind.
```

---

## Stitch prompt — Bağlamsal banner varyantları

Paywall açılmadan önce veya hero altında gösterilecek tetikleyici mesajlar:

```
Context trigger copy (pick one, Turkish, single line in warning or info banner):

- Wallet full: "15 kart limitine ulaştınız. Premium ile sınırsız kayıt."
- Manual trial used: "Ücretsiz elle/fotoğraf hakkınızı kullandınız."
- Own card limit: "Ücretsiz planda yalnızca 1 kendi kartınız olabilir."
- Generic upsell: "Premium ile cüzdanınızı sınırsız büyütün."
- After successful peer add (soft upsell, info not warning): "Ağınız büyüyor — Premium ile sınırsız devam edin."
```

---

## Ücretsiz vs Premium — gerçek ürün kuralları

| Özellik | Ücretsiz | Premium |
|---------|----------|---------|
| Kayıtlı kart cüzdanı | 15 | Sınırsız |
| Kendi kartlarım | 1 | 50 |
| Elle / fotoğrafla ekleme | 1 deneme (toplam) | Sınırsız |
| Kart ID / QR ile ekleme | ✓ | ✓ |
| Etkinlik grupları | ✓ | Sınırsız (UI mesajı) |
| Reklamlar | Interstitial (kart ekleme sonrası) | Yok |

> Fiyat (`₺149,99`) placeholder — RevenueCat / mağaza fiyatına göre güncelleyin.

---

## Dark mode eki

Global dark mode bloğuna ek olarak:

```
PAYWALL DARK MODE:
- Hero glow: primary #8FA8C4 at 12% opacity
- Comparison card surface: #1A2028, border #4A5568
- Selected plan fill: #28303A, border primary #8FA8C4
- Premium check icons: success #4ADE80 or #1F6B4F adjusted for dark
```

---

## Önerilen üretim sırası

1. Ana tam ekran paywall (default state)
2. Aynı layout + context banner variant (manuel limit)
3. Kompakt bottom sheet alternatif
4. Dark mode turu

## Kod entegrasyon notları

| Bileşen | Önerilen konum |
|---------|----------------|
| Tam ekran paywall page | `lib/features/subscriptions/presentation/pages/premium_paywall_page.dart` |
| Sheet fallback | Mevcut `wallet_upgrade_sheet.dart` güncelle |
| Satın alma | `purchaseWalletPremium()` → RevenueCat |
| Geri yükle | `restoreWalletPurchases()` |

## İlgili dosyalar

- `lib/core/config/revenuecat_config.dart` — `premium_wallet`, `$rc_monthly`
- `lib/features/saved_cards/domain/saved_cards_wallet_limits.dart`
- `lib/features/ads/` — premium kullanıcıda reklam yok
