# Cardence – Tema Renkleri

Uygulama: **dijital kartvizit**, profesyonel iletişim, ağ oluşturma. Tema renkleri **kurumsal**, **resmi** ve **okunabilir** bir deneyim için lacivert + nötr gri paleti kullanır.

---

## Kural: Tüm renkler AppColors’dan

**Uygulama genelinde tüm renkler `AppColors` (lib/core/theme/app_colors.dart) üzerinden kullanılır.**

- **Kullan:** `AppColors.primary`, `AppColors.surfaceLight`, `AppColors.textPrimary` vb.
- **Kullanma:** `Colors.blue`, `Colors.white`, `Color(0xFF...)`, `Colors.grey` gibi doğrudan Flutter `Colors` veya ham `Color()` değerleri.
- **İstisna:** Sadece şeffaflık için `Colors.transparent` kullanılabilir.
- Yeni bir renk gerekiyorsa önce `AppColors`’a eklenir, sonra kodda kullanılır.

---

## 1. Ana renkler (Primary)

| Renk | Hex | Kullanım |
|------|-----|----------|
| **Primary** | `#1B365D` | Ana butonlar, seçili durumlar, vurgu |
| **Primary dark** | `#122640` | Pressed / koyu vurgu |
| **Primary light** | `#2E4A73` | İkincil vurgu, ikon tonu |
| **Primary container** | `#D6DEE8` | Seçili nav, chip arka planı |
| **On primary container** | `#1B365D` | Container üzeri metin |

**Gerekçe:** Kurumsal lacivert güven ve resmiyet hissi verir; parlak teal/cyan tonlarından uzak, sakin bir palet.

---

## 2. İkincil (Secondary)

| Renk | Hex | Kullanım |
|------|-----|----------|
| **Secondary** | `#4A5568` | İkincil metin, ikonlar |
| **Secondary light** | `#718096` | Koyu temada ikincil öğeler |

---

## 3. Arka plan ve yüzey

| Renk | Hex | Kullanım |
|------|-----|----------|
| **Background light** | `#F4F5F7` | Scaffold (açık tema) |
| **Surface light** | `#FFFFFF` | Kartlar, AppBar, sheet |
| **Surface variant** | `#E8EBF0` | Bölüm arka planı, input fill |
| **Outline** | `#B8C0CC` | Kenarlıklar |
| **Outline variant** | `#DDE2E9` | Ayırıcılar |

---

## 4. Metin

| Renk | Hex | Kullanım |
|------|-----|----------|
| **Text primary** | `#1C2430` | Başlıklar, ana metin |
| **Text secondary** | `#5A6578` | Alt metin, caption |
| **Text disabled** | `#94A0B0` | Devre dışı |
| **Text on primary** | `#FFFFFF` | Primary üzeri metin |

---

## 5. Semantik renkler

| Renk | Hex | Kullanım |
|------|-----|----------|
| **Success** | `#1F6B4F` | Onay, kaydedildi |
| **Error** | `#B42318` | Hata |
| **Warning** | `#B54708` | Uyarı |
| **Info** | `#1E4A6E` | Bilgi (primary ile uyumlu koyu mavi) |

---

## 6. Koyu tema

| Renk | Hex | Kullanım |
|------|-----|----------|
| **Background dark** | `#0F1419` | Scaffold |
| **Surface dark** | `#1A2028` | Kartlar, AppBar |
| **Surface variant dark** | `#28303A` | Bölüm, input |
| **Primary (dark theme)** | `#8FA8C4` | Butonlar, seçili öğe |
| **Text primary dark** | `#ECEFF4` | Ana metin |
| **Text secondary dark** | `#A8B0BD` | Alt metin |

---

## 7. Özet palet (light)

```
Primary:            #1B365D
Primary container:  #D6DEE8
Secondary:          #4A5568
Background:         #F4F5F7
Surface:            #FFFFFF
Text primary:       #1C2430
Success / Error:    #1F6B4F / #B42318
```

Bu palet `lib/core/theme/app_colors.dart` ve `app_theme.dart` içinde kullanılır.
