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
| [02-login.md](./02-login.md) | Giriş |
| [03-register.md](./03-register.md) | Kayıt ol |
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
| [18-event-groups.md](./18-event-groups.md) | Etkinlik grupları (liste, detay, sheet'ler) |

### Profil / Kendi kartlarım

| Dosya | Ekran |
|-------|-------|
| [21-profile.md](./21-profile.md) | Profil, kart düzenle, görünüm, paylaşım |

### Ayarlar ve destek

| Dosya | Ekran |
|-------|-------|
| [25-settings.md](./25-settings.md) | Ayarlar |
| [26-support.md](./26-support.md) | Destek |

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
