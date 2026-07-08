# Cardence — Stitch UI Prompt Dokümantasyonu

Bu klasör, Cardence mobil uygulamasının her ekranı için **Google Stitch** (veya benzeri AI UI araçları) ile tutarlı tasarım üretmek amacıyla hazırlanmış prompt setini içerir.

## Nasıl kullanılır?

1. Her ekran için önce **[00-global-design-system.md](./00-global-design-system.md)** içeriğini prompt'un başına yapıştırın.
2. Ardından ilgili ekran dosyasındaki prompt'u ekleyin.
3. Stitch'e tek seferde gönderin veya flow modunda sırayla üretin.

## Tasarım ilkeleri

- **Dil:** Uygulama arayüzü Türkçe; prompt metinleri İngilizce (Stitch uyumluluğu için).
- **Platform:** iOS/Android mobil, 390×844 referans çerçeve.
- **Tema:** Kurumsal lacivert `#1B365D`, sakin kontrast, Material 3 ilhamlı, minimal gölge.
- **İmza bileşen:** ISO 7810 oranında çevrilebilir dijital kartvizit (`FlippablePersonCard`).

## Ekran indeksi

### Kimlik doğrulama

| Dosya | Ekran |
|-------|-------|
| [01-splash.md](./01-splash.md) | Splash / Yükleme |
| [02-login.md](./02-login.md) | Giriş (hero + form panel, e-posta/telefon, LinkedIn) |
| [03-register.md](./03-register.md) | Kayıt ol (ad/soyad, yasal onay, login ile görsel aile) |
| [04-forgot-password.md](./04-forgot-password.md) | Şifremi unuttum |

### Onboarding (5 adım)

| Dosya | Ekran |
|-------|-------|
| [05-onboarding.md](./05-onboarding.md) | Tüm onboarding adımları (1–5) |

### Ana kabuk — Kayıtlı kartlar

| Dosya | Ekran |
|-------|-------|
| [10-main-shell-bottom-nav.md](./10-main-shell-bottom-nav.md) | Alt navigasyon (referans) |
| [11-saved-cards.md](./11-saved-cards.md) | Kayıtlı kartlar (ana sekme) |
| [12-saved-card-detail.md](./12-saved-card-detail.md) | Kayıtlı kart detay |
| [13-add-card.md](./13-add-card.md) | Kart ekleme akışı (sheet + manuel / ID / fotoğraf) |
| [17-saved-cards-filter-sheet.md](./17-saved-cards-filter-sheet.md) | Filtre (bottom sheet) |

### Etkinlik grupları

| Dosya | Ekran |
|-------|-------|
| [18-event-groups.md](./18-event-groups.md) | Etkinlik grupları (liste, sheet'ler) |
| [19-event-group-detail.md](./19-event-group-detail.md) | Etkinlik detay |

### Profil / Kendi kartlarım

| Dosya | Ekran |
|-------|-------|
| [21-profile.md](./21-profile.md) | Profil, kart düzenle, görünüm, paylaşım |

### Ayarlar ve destek

| Dosya | Ekran |
|-------|-------|
| [25-settings.md](./25-settings.md) | Ayarlar |
| [26-support.md](./26-support.md) | Destek |

### App Store

| Dosya | Ekran |
|-------|-------|
| [30-app-store-screenshots.md](./30-app-store-screenshots.md) | App Store vitrin indeks |
| [30-app-store-screenshot-01-hero.md](./30-app-store-screenshot-01-hero.md) | Screenshot 1 — Dijital kimlik |
| [31-app-store-screenshot-02-wallet.md](./31-app-store-screenshot-02-wallet.md) | Screenshot 2 — Cüzdan |
| [32-app-store-screenshot-03-events.md](./32-app-store-screenshot-03-events.md) | Screenshot 3 — Etkinlik grupları |
| [33-app-store-screenshot-04-network-graph.md](./33-app-store-screenshot-04-network-graph.md) | Screenshot 4 — Ağ grafiği |
| [34-app-store-screenshot-05-card-detail.md](./34-app-store-screenshot-05-card-detail.md) | Screenshot 5 — Kart detay |

### Ortak bileşenler

| Dosya | Bileşen |
|-------|---------|
| [27-confirm-dialog.md](./27-confirm-dialog.md) | Onay diyaloğu |
| [28-wallet-quota-sheets.md](./28-wallet-quota-sheets.md) | Cüzdan kotası / yükseltme |
| [29-paywall.md](./29-paywall.md) | Premium paywall (tam ekran + sheet) |

## Önerilen üretim sırası (flow)

```
Splash → Login → Onboarding (1–5) → Saved Cards → Add Sheet →
Saved Card Detail → Event Groups → Profile → Card Edit → Settings
```

## İlgili dokümanlar

- [THEME_COLORS.md](../THEME_COLORS.md) — Renk token'ları
- [ARCHITECTURE.md](../ARCHITECTURE.md) — Uygulama mimarisi
- [CARD_DESIGN_PROMPTS.md](../CARD_DESIGN_PROMPTS.md) — Kart görsel tasarım prompt'ları
