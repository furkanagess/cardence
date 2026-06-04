# Cardence – Kart Tasarımı için Görsel Prompt’ları

Bu dosya, uygulamadaki **dijital kartvizit (card)** tasarımları için görsel üretirken kullanılabilecek prompt’ları içerir. Renkler ve oranlar `AppColors` ve mevcut kart yapısıyla uyumludur.

---

## Genel kurallar

- **Oran:** Kartvizit oranı **1,65 : 1** (genişlik : yükseklik), yaklaşık 85×55 mm hissi.
- **Renk paleti:** Primary `#1976D2`, surface `#FFFFFF` / `#1E1E2E`, metin `#1A2332` / `#E8EAED`, secondary `#546E7A`.
- **Stil:** Profesyonel, sade, okunabilir; gereksiz süsleme yok.

---

## 1. Ön yüz (Front) – Profesyonel kimlik

**Kullanım:** Kartın ön yüzü; isim, şirket, ünvan, iletişim özeti.

### Prompt (TR)

```
Dijital kartvizit ön yüzü, dikdörtgen yatay kart (oran 1.65:1). Beyaz veya çok açık gri zemin (#F5F7FA). Sol üstte veya üst ortada büyük puntolu, kalın isim (koyu lacivert #1A2332). Hemen altında ince çizgi veya boşlukla ayrılmış satırlar: şirket adı, ünvan (gri-mavi #546E7A). Alt bölümde e-posta ve telefon ikonlarıyla (mavi #1976D2) iletişim bilgileri. Minimal, kurumsal, gölgesiz veya hafif gölge. İllüstrasyon veya fotoğraf yok, sadece tipografi ve ikonlar. Flat design, modern UI.
```

### Prompt (EN)

```
Digital business card front face, horizontal rectangle aspect ratio 1.65:1. White or very light grey background (#F5F7FA). Top left or center: large bold name in dark navy (#1A2332). Below, subtle divider then company name and job title in grey-blue (#546E7A). Bottom section: email and phone with small blue icons (#1976D2). Minimal, corporate, no illustration or photo, typography and icons only. Flat design, modern UI, light shadow optional.
```

---

## 2. Arka yüz (Back) – İletişim ve marka

**Kullanım:** Kartın arka yüzü; iletişim vurgusu, linkler, uygulama markası.

### Prompt (TR)

```
Dijital kartvizit arka yüzü, aynı dikdörtgen oran (1.65:1). Beyaz zemin (#FFFFFF), ince kenarlık veya gölge. Üstte küçük başlık "İletişim" (gri #546E7A). Ortada isim tekrar (koyu #1A2332). E-posta, telefon, web, LinkedIn satırları; her biri küçük mavi ikon (#1976D2) ve metin. Alt kısımda hafif gri "Cardence" logosu veya yazı. Sade, profesyonel, tipografi odaklı, flat design.
```

### Prompt (EN)

```
Digital business card back face, same 1.65:1 rectangle. White background (#FFFFFF), thin border or soft shadow. Top: small label "Contact" in grey (#546E7A). Center: name again in dark (#1A2332). Rows for email, phone, website, LinkedIn with small blue icons (#1976D2). Bottom: subtle "Cardence" wordmark in light grey. Clean, professional, typography-focused, flat design.
```

---

## 3. Kart – tek görsel (ön + arka ayrımı)

**Kullanım:** Tek görselde ön ve arka yüzün yan yana veya üst üste gösterimi.

### Prompt (TR)

```
İki dijital kartvizit yan yana: solda ön yüz (isim, şirket, ünvan, iletişim ikonları), sağda arka yüz (İletişim başlığı, e-posta/telefon/link satırları, altta Cardence). Her iki kart da aynı beyaz/açık gri zemin, mavi vurgu (#1976D2), koyu metin (#1A2332). Oran 1.65:1, hafif gölge, minimal kurumsal stil. 3D değil, düz mockup.
```

### Prompt (EN)

```
Two digital business cards side by side: left card front (name, company, title, contact icons), right card back (Contact header, email/phone/links rows, Cardence at bottom). Same white/light grey background, blue accent (#1976D2), dark text (#1A2332). Aspect 1.65:1, soft shadow, minimal corporate style. Flat mockup, not 3D.
```

---

## 4. Koyu tema kartı

**Kullanım:** Dark mode’da kullanılacak kart görseli.

### Prompt (TR)

```
Dijital kartvizit, koyu tema. Arka plan koyu gri (#1E1E2E veya #121212). Metin açık gri (#E8EAED). Vurgu rengi açık mavi (#42A5F5). İsim büyük ve kalın, altında şirket/ünvan ve iletişim satırları. Oran 1.65:1, minimal, ince kenarlık veya hafif glow. Profesyonel dark UI, flat design.
```

### Prompt (EN)

```
Digital business card, dark theme. Background dark grey (#1E1E2E or #121212). Text light grey (#E8EAED). Accent light blue (#42A5F5). Name large and bold, below company/title and contact rows. Aspect 1.65:1, minimal, thin border or subtle glow. Professional dark UI, flat design.
```

---

## 5. Telefon ekranında kart (in-app)

**Kullanım:** Kartın uygulama içinde, ekranda nasıl görüneceğini göstermek.

### Prompt (TR)

```
Mobil uygulama ekranı, üstte "Kendi Kartlarım" başlığı. Ortada tek bir dijital kartvizit (oran 1.65:1), beyaz kart hafif gölgeli, yuvarlatılmış köşeler. Kartta isim, şirket, ünvan, iletişim ikonları. Sağ altta küçük flip/çevir ikonu. Ekran arka planı açık gri (#F5F7FA). Alt kısımda ince bottom navigation. Minimal, iOS/Android tarzı UI mockup.
```

### Prompt (EN)

```
Mobile app screen, header "My Cards". Center: single digital business card (1.65:1), white card with soft shadow, rounded corners. Card shows name, company, title, contact icons. Small flip icon bottom right. Screen background light grey (#F5F7FA). Thin bottom nav at bottom. Minimal, iOS/Android style UI mockup.
```

---

## 6. Flip animasyonu / iki yüz

**Kullanım:** Kartın çevrildiği anı veya ön-arka geçişini vurgulayan görsel.

### Prompt (TR)

```
Dijital kartvizit çevrilirken: ortada tek kart, yarısı ön yüz (isim, şirket), yarısı arka yüz (İletişim, linkler) gibi bükülmüş veya 3D flip geçişi. Renkler beyaz zemin, mavi vurgu (#1976D2), koyu metin. Oran 1.65:1. Profesyonel, yumuşak gölge, motion blur veya hafif perspektif. Ürün görseli / app feature illüstrasyonu.
```

### Prompt (EN)

```
Digital business card mid-flip: single card in center, half front (name, company), half back (Contact, links), bent or 3D flip transition. Colors white background, blue accent (#1976D2), dark text. Aspect 1.65:1. Professional, soft shadow, optional motion blur or slight perspective. Product / app feature illustration.
```

---

## 7. Özet tablo (referans)

| Öğe              | Değer / Hex |
| ---------------- | ----------- |
| Kart oranı       | 1.65 : 1    |
| Primary          | #1976D2     |
| Primary light    | #42A5F5     |
| Surface light    | #FFFFFF     |
| Surface dark     | #1E1E2E     |
| Text primary     | #1A2332     |
| Text secondary   | #546E7A     |
| Text dark        | #E8EAED     |
| Background light | #F5F7FA     |

Bu prompt’ları doğrudan görsel üretici (ör. DALL·E, Midjourney, Ideogram) veya tasarım brief’i olarak kullanabilirsin. İstediğin stili vurgulamak için “minimal”, “corporate”, “flat design”, “no illustration” gibi ifadeleri ekleyebilir veya sadeleştirebilirsin.
