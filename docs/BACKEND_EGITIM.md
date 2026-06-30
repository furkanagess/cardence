# Cardence Backend Sistemi — Sıfırdan Eğitim Rehberi

Bu doküman, Cardence projesindeki backend sistemini **hiç bilmeyen birine** adım adım, birim birim anlatır.

**Hedef kitle:** Backend, API, veritabanı veya sunucu kavramlarına aşina olmayan geliştiriciler veya proje yeni katılan ekip üyeleri.

**Son güncelleme:** 2026-06

---

## İçindekiler

1. [Birim 1 — Backend nedir, neden var?](#birim-1--backend-nedir-neden-var)
2. [Birim 2 — Cardence’in genel mimarisi](#birim-2--cardencein-genel-mimarisi)
3. [Birim 3 — Teknoloji yığını](#birim-3--teknoloji-yığını)
4. [Birim 4 — Backend proje yapısı (Clean Architecture)](#birim-4--backend-proje-yapısı-clean-architecture)
5. [Birim 5 — Temel kavramlar (domain)](#birim-5--temel-kavramlar-domain)
6. [Birim 6 — Veritabanı (PostgreSQL)](#birim-6--veritabanı-postgresql)
7. [Birim 7 — Kimlik doğrulama (Auth & JWT)](#birim-7--kimlik-doğrulama-auth--jwt)
8. [Birim 8 — API sözleşmesi](#birim-8--api-sözleşmesi)
9. [Birim 9 — Endpoint haritası (modül modül)](#birim-9--endpoint-haritası-modül-modül)
10. [Birim 10 — Flutter ↔ Backend entegrasyonu](#birim-10--flutter--backend-entegrasyonu)
11. [Birim 11 — Offline-first ve senkronizasyon](#birim-11--offline-first-ve-senkronizasyon)
12. [Birim 12 — QR kart paylaşımı](#birim-12--qr-kart-paylaşımı)
13. [Birim 13 — Premium abonelik (RevenueCat)](#birim-13--premium-abonelik-revenuecat)
14. [Birim 14 — Production ortamı ve deploy](#birim-14--production-ortamı-ve-deploy)
15. [Birim 15 — Yerel geliştirme (hands-on)](#birim-15--yerel-geliştirme-hands-on)
16. [Birim 16 — Sözlük ve referanslar](#birim-16--sözlük-ve-referanslar)

---

## Birim 1 — Backend nedir, neden var?

### 1.1 Backend ne demek?

**Backend**, kullanıcının telefonunda veya tarayıcısında çalışmayan, **sunucuda** çalışan yazılımdır.

Basit bir analoji:

| Rol | Cardence’te karşılığı |
|-----|----------------------|
| Mağaza vitrini (gördüğün kısım) | Flutter mobil uygulama |
| Depo, kasa, güvenlik (arkada çalışan) | .NET Backend API |
| Defter / kayıt sistemi | PostgreSQL veritabanı |

Kullanıcı uygulamada bir butona basar → uygulama sunucuya istek gönderir → sunucu işlemi yapar → sonucu geri döner.

### 1.2 Cardence backend’i ne işe yarar?

Cardence bir **dijital kartvizit cüzdanı** uygulamasıdır. Backend şu ihtiyaçları karşılar:

| İhtiyaç | Backend olmadan | Backend ile |
|---------|-----------------|-------------|
| Hesap açma / giriş | Sadece cihazda | Her cihazda aynı hesap |
| Kartları kaydetme | Sadece telefonda | Sunucuda yedek + senkron |
| QR ile kart paylaşma | QR içinde tüm veri | `cardId` ile sunucudan çözümleme |
| Cüzdan kotası (15 / 200) | Kolayca bypass | Sunucuda zorunlu kural |
| Premium abonelik | Güvenilmez | RevenueCat webhook ile doğrulama |
| Etkinlik grupları | Local only | Tüm cihazlarda aynı gruplar |
| Ağ grafiği (network graph) | Mümkün değil | Sunucuda ilişki analizi |

### 1.3 Önemli: Firebase Auth kullanılmıyor

Cardence **kendi backend’ini** kullanır. Oturum yönetimi **Firebase Auth** ile değil, **Cardence API + JWT token** ile yapılır.

```
❌ Eski yaklaşım:  Flutter → Firebase Auth → Firestore
✅ Mevcut yaklaşım: Flutter → Cardence API (cardenceapi.app) → PostgreSQL
```

`pubspec.yaml` içinde `firebase_core` gibi paketler legacy olarak durabilir; asıl oturum akışı backend JWT üzerinedir.

---

## Birim 2 — Cardence’in genel mimarisi

### 2.1 Sistem diyagramı

```
┌─────────────────────┐         HTTPS          ┌─────────────────────────┐
│   Flutter Uygulama  │ ◄────────────────────► │   Cardence .NET API     │
│   (iOS / Android)   │   JSON + JWT Bearer    │   cardenceapi.app       │
└─────────────────────┘                        └───────────┬─────────────┘
         │                                                  │
         │ SharedPreferences                                │ EF Core (ORM)
         │ (offline önbellek)                               ▼
         ▼                                      ┌─────────────────────────┐
   Tema, dil ayarları                           │      PostgreSQL         │
   (backend'e gitmez)                           │   users, business_cards │
                                               │   saved_cards, ...      │
                                               └─────────────────────────┘
```

### 2.2 Tek bir isteğin yolculuğu

Örnek: Kullanıcı cüzdanına yeni bir kart ekliyor.

```
1. Kullanıcı "Kaydet" butonuna basar
2. Flutter Cubit → Use Case → Repository çağırır
3. Repository → RemoteDataSource → DioApiClient
4. HTTP POST https://cardenceapi.app/SaveSavedCard
   Header: Authorization: Bearer eyJhbGciOi...
   Body:   { "cardId": "abc123", "displayName": "Ali", ... }
5. Backend JWT'yi doğrular → userId çıkarır
6. İş kuralı: Kota doldu mu? Duplicate var mı?
7. PostgreSQL'e INSERT
8. JSON yanıt: { "success": true, "data": { ... } }
9. Flutter ekranı günceller + local cache'e yazar
```

### 2.3 Monorepo yapısı

Bu proje **tek Git reposu** içinde iki uygulama barındırır:

```
cardence/                  ← Repo kökü (Flutter projesi)
├── lib/                   ← Mobil uygulama kodu
├── backend/               ← .NET API kodu
│   ├── Cardence.Api/
│   ├── Cardence.Application/
│   ├── Cardence.Domain/
│   ├── Cardence.Infrastructure/
│   └── database/          ← PostgreSQL Docker/script
└── docs/                  ← Dokümantasyon
```

---

## Birim 3 — Teknoloji yığını

Her parçanın ne olduğunu anlamak, sistemi okumayı kolaylaştırır.

### 3.1 Mobil taraf

| Teknoloji | Görev |
|-----------|-------|
| **Flutter (Dart)** | Kullanıcı arayüzü |
| **Dio** | HTTP istemcisi (API çağrıları) |
| **flutter_bloc / Cubit** | State management |
| **SharedPreferences** | Cihazda JSON cache (offline) |
| **RevenueCat SDK** | App Store / Play Store abonelik |

### 3.2 Backend taraf

| Teknoloji | Görev |
|-----------|-------|
| **ASP.NET Core (.NET 10)** | HTTP sunucusu, routing, middleware |
| **Entity Framework Core** | C# sınıflarını SQL tablolarına bağlar (ORM) |
| **PostgreSQL 16** | Kalıcı veri deposu |
| **JWT Bearer** | Token tabanlı kimlik doğrulama |
| **FluentValidation** | Gelen veriyi doğrulama |
| **Serilog** | Loglama |
| **Swagger** | API dokümantasyonu (geliştirme) |

### 3.3 Altyapı

| Teknoloji | Görev |
|-----------|-------|
| **Railway** | Production API hosting (Docker) |
| **Cloudflare** | DNS, CDN, tunnel |
| **RevenueCat** | Abonelik doğrulama + webhook |

---

## Birim 4 — Backend proje yapısı (Clean Architecture)

Backend, **Clean Architecture** ile katmanlara ayrılmıştır. Her katmanın tek sorumluluğu vardır; dış katman iç katmana bağımlıdır, tersi olmaz.

### 4.1 Katmanlar

```
backend/
├── Cardence.Api/            → HTTP giriş kapısı (Controller'lar, Swagger, middleware)
├── Cardence.Application/    → İş mantığı, DTO'lar, validator'lar, service'ler
├── Cardence.Domain/         → Saf iş kuralları (Entity'ler, enum'lar, exception'lar)
├── Cardence.Infrastructure/ → DB, JWT, dosya depolama, dış servis entegrasyonları
└── Cardence.Tests/          → Unit testler
```

### 4.2 Bağımlılık yönü

```
                    ┌─────────────┐
                    │  Cardence   │
                    │    .Api     │  ← Dış dünya (HTTP)
                    └──────┬──────┘
                           │
                    ┌──────▼──────────────┐
                    │  Cardence           │
                    │  .Infrastructure    │  ← DB, JWT, storage
                    └──────┬──────────────┘
                           │
                    ┌──────▼──────────────┐
                    │  Cardence           │
                    │  .Application       │  ← Use case'ler, DTO'lar
                    └──────┬──────────────┘
                           │
                    ┌──────▼──────────────┐
                    │  Cardence           │
                    │  .Domain            │  ← Saf entity'ler (en iç)
                    └─────────────────────┘
```

### 4.3 Her katmanın görevi

| Katman | Ne yapar? | Ne yapmaz? |
|--------|-----------|------------|
| **Domain** | `User`, `SavedCard` gibi entity tanımları | HTTP, DB, Flutter import etmez |
| **Application** | "Kart kaydet", "Giriş yap" servisleri | Doğrudan SQL yazmaz |
| **Infrastructure** | PostgreSQL repository, JWT üretimi | HTTP endpoint tanımlamaz |
| **Api** | Controller'lar, istek/yanıt dönüşümü | İş mantığı içermez (ince tutulur) |

### 4.4 Controller → Service → Repository akışı

```
HTTP isteği gelir
    ↓
Controller (Cardence.Api)
    ↓
Service (Cardence.Application)  ← iş kuralları burada
    ↓
Repository interface (Application)
    ↓
Repository impl (Infrastructure)  ← EF Core ile DB'ye yazar
    ↓
PostgreSQL
```

Bu yapı, mobil taraftaki `presentation → domain → data` ayrımına benzer bir fikirdir.

---

## Birim 5 — Temel kavramlar (domain)

Backend'i anlamak için Cardence'in "dünyasındaki" kavramları ayırt etmek gerekir.

### 5.1 User (Kullanıcı)

Giriş yapan hesap. Her verinin sahibi.

- Tablo: `users`
- JWT token içindeki `sub` claim'i bu kullanıcının UUID'sidir.
- Tüm API sorguları `WHERE user_id = <sub>` ile filtrelenir.

### 5.2 BusinessCard (Kendi kartvizitin)

**Senin** oluşturduğun dijital kart. Profil, onboarding ve "Kartlarım" ekranlarında düzenlenir.

- Tablo: `business_cards`
- `cardId`: Global benzersiz ID — QR paylaşımında kullanılır.
- Bir kullanıcının birden fazla BusinessCard'ı olabilir.

### 5.3 SavedCard (Cüzdandaki kart)

Başka birinden aldığın kartın **senin cüzdanındaki kopyası**.

- Tablo: `saved_cards`
- Aynı `cardId`'yi referans alır ama senin notun, kayıt tarihin, grup bağlantıların vardır.
- Kullanıcı başına aynı `cardId` yalnızca **bir kez** eklenebilir.

### 5.4 EventGroup (Etkinlik grubu)

Networking etkinliği veya proje grubu.

- Tablo: `event_groups` + `saved_card_event_groups` (many-to-many)
- Yalnızca **SavedCard**'lara bağlanır; kendi BusinessCard'ına değil.
- Grup silinince tüm SavedCard'lardan bağlantı otomatik temizlenir.

### 5.5 WalletEntitlement (Cüzdan kotası)

Kayıtlı kart limiti.

| Plan | Limit |
|------|-------|
| Free | 15 kart |
| Premium | 200 kart |

- Tablo: `wallet_entitlements`
- Limit aşılırsa backend `403 WALLET_LIMIT_REACHED` döner.

### 5.6 CardSharePayload (QR paylaşım verisi)

QR koduna gömülen kompakt JSON. Kısa anahtarlar kullanır:

| Anahtar | Alan |
|---------|------|
| `id` | cardId |
| `n` | displayName |
| `e` | email |
| `p` | phone |
| `c` | company |
| ... | ... |

### 5.7 Kritik ayrım: BusinessCard ≠ SavedCard

```
BusinessCard                    SavedCard
─────────────────              ─────────────────
Senin kartın                   Başkasının kartının kopyası
Global paylaşılabilir cardId   Senin cüzdan kaydın
business_cards tablosu         saved_cards tablosu
Profil / onboarding            Kaydedilen Kartlar ekranı
```

Bu ayrımı anlamadan backend kodunu okumak zordur.

---

## Birim 6 — Veritabanı (PostgreSQL)

### 6.1 PostgreSQL nedir?

**PostgreSQL**, ilişkisel bir veritabanıdır. Veriler **tablolarda** satır olarak tutulur; tablolar **foreign key** ile birbirine bağlanır.

Cardence backend'inin kalıcı hafızası budur. API yeniden başlasa bile veriler kaybolmaz.

### 6.2 Ana tablolar

| Tablo | Ne tutar? |
|-------|-----------|
| `users` | Hesap bilgileri (email, telefon, displayName, onboardingCompleted) |
| `user_auth_providers` | Google / Apple / LinkedIn hesap eşlemesi |
| `auth_refresh_tokens` | Oturum yenileme token'ları |
| `business_cards` | Kullanıcıların kendi kartvizitleri |
| `saved_cards` | Cüzdana kaydedilen kartlar |
| `event_groups` | Etkinlik grupları |
| `saved_card_event_groups` | Kart ↔ grup many-to-many ilişkisi |
| `wallet_entitlements` | Free / Premium kota |
| `card_interactions` | Profil istatistikleri (tıklama vb.) |
| `subscription_events` | RevenueCat webhook kayıtları |
| `support_requests` | Destek talepleri |

### 6.3 ER ilişki diyagramı (basitleştirilmiş)

```
User
 ├── BusinessCard (1:N)     → Kendi kartlarım
 ├── SavedCard (1:N)        → Cüzdanım
 ├── EventGroup (1:N)       → Etkinlik gruplarım
 └── WalletEntitlement (1:1) → Kota bilgim

SavedCard ←→ EventGroup     → Many-to-many (saved_card_event_groups)
```

### 6.4 Güvenlik kuralı: user_id filtresi

Her kullanıcıya özel veri **mutlaka** `user_id` ile filtrelenir:

```sql
-- Doğru: sadece giriş yapan kullanıcının kartları
SELECT * FROM saved_cards WHERE user_id = @currentUserId;

-- Yanlış: tüm kullanıcıların kartları (asla yapılmaz)
SELECT * FROM saved_cards;
```

JWT'den çıkarılan `sub` claim → `@currentUserId` olur.

### 6.5 Mobil uygulama DB'ye bağlanmaz

```
❌ Flutter → PostgreSQL (doğrudan bağlantı yok)
✅ Flutter → Cardence API → PostgreSQL
```

Bu, güvenlik ve mimari açısından doğru tasarımdır. Veritabanı şifresi mobil uygulamada bulunmaz.

### 6.6 EF Core ve Migration

**EF Core**, C# entity sınıflarını SQL tablolarına map eder. Şema değişikliği **migration** dosyalarıyla yönetilir:

```
backend/Cardence.Infrastructure/Migrations/
├── 20260605181151_AddAuthRefreshTokens.cs
├── 20260605220453_AddSavedCardsAndWallet.cs
├── 20260610110145_AddEventGroups.cs
└── ...
```

API başlarken migration'lar otomatik uygulanır (`Program.cs`).

---

## Birim 7 — Kimlik doğrulama (Auth & JWT)

### 7.1 JWT nedir?

**JWT (JSON Web Token)**, sunucunun "bu kullanıcı giriş yapmış" dediği **imzalı** bir metin parçasıdır.

Cardence **stateless** auth kullanır: sunucu oturum tablosu tutmaz; her istekte token doğrulanır.

### 7.2 İki token türü

| Token | Ömür | Kullanım |
|-------|------|----------|
| **accessToken** | Kısa (~15–60 dk) | Her API isteğinde `Authorization: Bearer ...` header'ı |
| **refreshToken** | Uzun (günler/haftalar) | Access token süresi dolunca yeni token almak için |

### 7.3 Giriş akışı (adım adım)

```
Adım 1: Kullanıcı email + şifre girer
Adım 2: Flutter → POST /Authentication { email, password }
Adım 3: Backend → users tablosunda kullanıcıyı bulur, şifreyi doğrular
Adım 4: Backend → accessToken + refreshToken + userId üretir
Adım 5: Flutter → token'ları cihazda saklar (AuthLocalDataSource)
Adım 6: Sonraki istekler → Authorization: Bearer <accessToken>
Adım 7: Token süresi dolunca → POST /RefreshAuthentication { refreshToken }
Adım 8: Yeni accessToken alınır, oturum devam eder
```

### 7.4 Desteklenen giriş yöntemleri

| Yöntem | Endpoint | Durum |
|--------|----------|-------|
| Email + şifre | `POST /Authentication` | ✅ Çalışıyor |
| Telefon + şifre | `POST /LoginWithPhone` | ✅ Çalışıyor |
| Kayıt | `POST /Register` | ✅ Çalışıyor |
| OTP gönder | `POST /SendOTP` | ✅ Çalışıyor |
| Şifre sıfırla | `POST /ForgotPassword`, `/ResetPassword` | ✅ Çalışıyor |
| LinkedIn | `POST /LoginWithLinkedIn` | ✅ Backend hazır |
| Google | `POST /LoginWithGoogle` | 🔜 Planlandı |
| Apple | `POST /LoginWithApple` | 🔜 Planlandı |
| Oturum yenile | `POST /RefreshAuthentication` | ✅ Çalışıyor |

### 7.5 Flutter tarafında token yönetimi

Üç parça birlikte çalışır:

| Bileşen | Dosya | Görev |
|---------|-------|-------|
| `AuthLocalDataSource` | `lib/features/auth/data/datasources/` | Token'ları cihazda saklar |
| `AuthTokenCoordinator` | `lib/core/auth/auth_token_coordinator.dart` | Token süresi dolunca otomatik yeniler |
| `DioApiClient` | `lib/core/network/dio_api_client.dart` | Her istekte geçerli token'ı header'a ekler |

401 alınırsa: bir kez refresh dener → başarısızsa oturum sonlandırılır ve login ekranına yönlendirilir.

### 7.6 API base URL

```dart
// lib/core/network/api_config.dart
static const String productionBaseUrl = 'https://cardenceapi.app';
```

Yerel geliştirme override:

```bash
flutter run --dart-define=API_BASE_URL=http://localhost:5241
```

---

## Birim 8 — API sözleşmesi

Mobil uygulama ile backend arasındaki "ortak dil" budur.

### 8.1 URL kuralları

| Kural | Değer | Örnek |
|-------|-------|-------|
| Path isimlendirme | PascalCase, düz path | `/SaveBusinessCard` |
| API prefix | Yok | `/api/v1` kullanılmaz |
| HTTP metodu | REST convention | GET okuma, POST oluşturma, PUT güncelleme, DELETE silme |
| Auth header | Bearer token | `Authorization: Bearer eyJhbG...` |

### 8.2 Standart yanıt zarfı (envelope)

Her yanıt aynı yapıda gelir:

**Başarılı:**
```json
{
  "success": true,
  "data": { "cardId": "abc123", "displayName": "Ali" },
  "error": null,
  "traceId": "abc-123-def"
}
```

**Hatalı:**
```json
{
  "success": false,
  "data": null,
  "error": {
    "code": "WALLET_LIMIT_REACHED",
    "message": "Cüzdan limitine ulaştınız."
  },
  "traceId": "xyz-789"
}
```

Flutter tarafında `ApiResponseParser` (`lib/core/network/api_response_parser.dart`) bu zarfı ayrıştırır.

### 8.3 Önemli hata kodları

| Kod | HTTP | Ne zaman? |
|-----|------|-----------|
| `WALLET_DUPLICATE_CARD` | 409 | Aynı kart zaten cüzdanda |
| `WALLET_LIMIT_REACHED` | 403 | Kota doldu (15 veya 200) |
| `CARD_NOT_FOUND` | 404 | Kart bulunamadı |
| `INVALID_CARD_PAYLOAD` | 400 | Geçersiz veri gönderildi |
| `DUPLICATE_EVENT_GROUP_NAME` | 409 | Aynı isimde grup var |

### 8.4 DTO uyumu (Backend ↔ Flutter)

JSON property adları **birebir aynı** olmalıdır (camelCase):

| Backend DTO | Flutter Model |
|-------------|---------------|
| `BusinessCardDto` | `OnboardingCardDraftModel` |
| `SavedCardDto` | `SavedCardModel` |
| `EventGroupDto` | `EventGroupModel` |
| `CardSharePayload` | `CardSharePayload` |

Yeni alan eklerken **hem backend DTO'yu hem Flutter model'i** güncellemek gerekir.

### 8.5 Özel format kuralları

| Alan | Format |
|------|--------|
| `savedAt` | Unix epoch **milliseconds** |
| Renkler | Hex `#RRGGBB` |
| `cardId` manuel giriş | `^[a-zA-Z0-9\-_]{8,}$` |

---

## Birim 9 — Endpoint haritası (modül modül)

### 9.1 Authentication modülü

**Controller:** `AuthenticationController`

| Method | Path | Auth? | Açıklama |
|--------|------|-------|----------|
| POST | `/Authentication` | Hayır | Email + şifre ile giriş |
| POST | `/LoginWithPhone` | Hayır | Telefon + şifre ile giriş |
| POST | `/LoginWithEmail` | Hayır | Email OTP ile giriş |
| POST | `/LoginWithLinkedIn` | Hayır | LinkedIn OAuth |
| POST | `/Register` | Hayır | Yeni hesap oluştur |
| POST | `/SendOTP` | Hayır | OTP kodu gönder |
| POST | `/RefreshAuthentication` | Hayır | Token yenile |
| POST | `/ForgotPassword` | Hayır | Şifre sıfırlama OTP |
| POST | `/ResetPassword` | Hayır | Yeni şifre belirle |
| GET | `/Me` | Evet | Profil bilgisi |
| POST | `/CompleteOnboarding` | Evet | Onboarding tamamla |
| POST | `/UploadProfilePhoto` | Evet | Profil fotoğrafı yükle (multipart) |

### 9.2 Business Cards modülü

**Controller:** `BusinessCardsController`

| Method | Path | Auth? | Açıklama |
|--------|------|-------|----------|
| GET | `/BusinessCards` | Evet | Tüm kartlarım |
| GET | `/BusinessCard` | Evet | Tek kart (cardId ile) |
| POST | `/SaveBusinessCard` | Evet | Yeni kart oluştur |
| PUT | `/UpdateBusinessCard` | Evet | Kart güncelle |
| DELETE | `/DeleteBusinessCard` | Evet | Kart sil |
| GET | `/BusinessCardShare` | Evet | QR paylaşım payload'ı |
| GET | `/ProfileStats` | Evet | Profil istatistikleri |

### 9.3 Wallet / Saved Cards modülü

**Controller:** `SavedCardsController`

| Method | Path | Auth? | Açıklama |
|--------|------|-------|----------|
| GET | `/SavedCards` | Evet | Cüzdan listesi |
| POST | `/SaveSavedCard` | Evet | Karta ekle |
| PUT | `/UpdateSavedCard` | Evet | Not / renk güncelle |
| DELETE | `/DeleteSavedCard` | Evet | Cüzdandan sil |
| GET | `/WalletQuota` | Evet | Kota bilgisi (15/200) |
| POST | `/UpgradeWalletPlan` | Evet | Premium yükselt |

### 9.4 Event Groups modülü

**Controller:** `EventGroupsController`

| Method | Path | Auth? | Açıklama |
|--------|------|-------|----------|
| GET | `/EventGroups` | Evet | Grup listesi |
| POST | `/SaveEventGroup` | Evet | Grup oluştur |
| PUT | `/UpdateEventGroup` | Evet | Grup güncelle |
| DELETE | `/DeleteEventGroup` | Evet | Grup sil |
| POST | `/UploadEventGroupPhoto` | Evet | Grup fotoğrafı yükle |
| POST | `/LinkEventGroupCards` | Evet | Kartları gruba bağla |
| DELETE | `/UnlinkEventGroupCard` | Evet | Bağlantıyı kaldır |
| GET | `/EventGroupCards` | Evet | Gruptaki kartlar |

### 9.5 Public Cards modülü

**Controller:** `PublicCardsController`

| Method | Path | Auth? | Açıklama |
|--------|------|-------|----------|
| GET | `/PublicBusinessCardShare` | Hayır | Giriş yapmadan kart okuma (QR) |
| POST | `/PublicBusinessCardContactClick` | Hayır | İletişim tıklama istatistiği |

### 9.6 Diğer modüller

| Controller | Endpoint'ler | Açıklama |
|------------|-------------|----------|
| `NetworkGraphController` | `/NetworkGraph`, `/NetworkGraphPath` | Ağ grafiği analizi |
| `PlanEntitlementsController` | `/PlanEntitlements` | Plan hakları |
| `RevenueCatWebhookController` | `/RevenueCatWebhook` | Abonelik olayları (sunucudan sunucuya) |
| `SupportController` | `/SubmitSupportRequest` | Destek talebi |
| `HealthController` | `/Health`, `/health/status` | Sunucu sağlık kontrolü |
| `LinkedInOAuthController` | `/auth/linkedin/callback` | LinkedIn OAuth callback |

---

## Birim 10 — Flutter ↔ Backend entegrasyonu

### 10.1 Mobil Clean Architecture katmanları

```
Presentation (Page / Widget / Cubit)
        ↓
    Use Case (domain/usecases/)
        ↓
Repository interface (domain/repositories/)  ← abstract
        ↓
RepositoryImpl (data/repositories/)
        ↓
    ├── RemoteDataSource  →  DioApiClient  →  Cardence API
    └── LocalDataSource   →  SharedPreferences (offline cache)
```

### 10.2 RemoteDataSource dosyaları

Her feature'ın backend ile konuşan data source'u vardır:

| Feature | Remote DataSource |
|---------|-------------------|
| Auth | `lib/features/auth/data/datasources/auth_remote_datasource.dart` |
| Business Cards | `lib/features/business_cards/data/datasources/business_card_remote_datasource.dart` |
| Saved Cards | `lib/features/saved_cards/data/datasources/saved_card_remote_datasource.dart` |
| Public Cards | `lib/features/saved_cards/data/datasources/public_business_card_remote_datasource.dart` |
| Event Groups | `lib/features/event_groups/data/datasources/event_group_remote_datasource.dart` |
| Network Graph | `lib/features/network_graph/data/datasources/network_graph_remote_datasource.dart` |
| Plans | `lib/features/plans/data/datasources/plan_remote_datasource.dart` |
| Support | `lib/features/support/data/datasources/support_remote_datasource.dart` |

### 10.3 DioApiClient — paylaşılan HTTP istemcisi

Tüm remote data source'lar `DioApiClient` kullanır:

```dart
// lib/core/network/dio_api_client.dart (özet)
class DioApiClient {
  Future<Map<String, dynamic>> get(String path, {String? accessToken, ...});
  Future<Map<String, dynamic>> post(String path, {Map body, String? accessToken, ...});
  Future<Map<String, dynamic>> put(String path, {...});
  Future<void> delete(String path, {...});
  Future<Map<String, dynamic>> postMultipart(String path, {FormData formData, ...});
}
```

Özellikler:
- Otomatik `Authorization: Bearer` header ekleme
- 401 alınca token refresh + retry
- Standart envelope ayrıştırma

### 10.4 Feature → Backend modül eşlemesi

| Flutter Feature | Backend Modül | Backend'e gider mi? |
|-----------------|---------------|---------------------|
| `auth` | Authentication | ✅ Evet |
| `onboarding` | BusinessCards | ✅ Evet |
| `my_cards` / `profile` | BusinessCards | ✅ Evet |
| `saved_cards` | Wallet (SavedCards) | ✅ Evet |
| `event_groups` | EventGroups | ✅ Evet |
| `network_graph` | NetworkGraph | ✅ Evet |
| `subscriptions` | RevenueCat + PlanEntitlements | ✅ Evet (webhook) |
| `support` | Support | ✅ Evet |
| `settings` (tema, dil) | — | ❌ Hayır (cihaz-local) |
| `ads` | — | ❌ Hayır (AdMob client-side) |

---

## Birim 11 — Offline-first ve senkronizasyon

### 11.1 Strateji

Cardence **offline-first** çalışır: uygulama internet olmadan da açılır ve son bilinen veriyi gösterir.

```
İnternet VAR  +  Giriş YAPILMIŞ  →  Sunucu "source of truth", local cache güncellenir
İnternet YOK  veya  Sunucu ERİŞİLEMEZ  →  Local cache gösterilir
Giriş YOK  →  Tamamen local çalışır (demo modu)
```

### 11.2 Repository'deki tipik akış

```dart
// saved_card_repository_impl.dart (mantık özeti)
Future<List<SavedCard>> getSavedCards() async {
  final token = await _tryAccessToken();
  if (token != null) {
    try {
      // 1. Sunucudan çek
      final remoteCards = await _remote.getSavedCards(accessToken: token);
      // 2. Local alanları birleştir (fotoğraf path vb.)
      final mergedCards = _mergeWithLocal(remoteCards);
      // 3. Cache güncelle
      await _local.replaceAll(mergedCards);
      return mergedCards;
    } catch (_) {
      // Sunucu erişilemezse local'e düş
    }
  }
  // 4. Offline fallback
  return await _local.getSavedCards();
}
```

### 11.3 Ne local'de kalır, ne sunucuya gider?

| Veri | Local (SharedPreferences) | Backend (PostgreSQL) |
|------|--------------------------|---------------------|
| Kart listesi | ✅ Cache | ✅ Source of truth |
| Tema tercihi | ✅ Tek kaynak | ❌ Gitmez |
| Dil tercihi | ✅ Tek kaynak | ❌ Gitmez |
| Auth token'ları | ✅ Tek kaynak | ❌ (refresh token DB'de) |
| Fiziksel kart fotoğrafları | ✅ Dosya sistemi | ❌ (henüz) |
| Profil fotoğrafı | ❌ | ✅ Sunucuda |

---

## Birim 12 — QR kart paylaşımı

### 12.1 İki mod

**Mod A — Tam offline (peer-to-peer):**
- QR içinde kartın tüm JSON'u taşınır.
- Okuyan taraf doğrudan cüzdanına yazar.
- Sunucu gerekmez.

**Mod B — Sunucu destekli (cardId referansı):**
- QR yalnızca `cardId` taşır.
- Alan kullanıcı sunucudan kart bilgisini çeker:

```
GET /PublicBusinessCardShare?cardId=abc123   (auth gerekmez)
POST /SaveSavedCard                           (auth gerekir)
```

Mod B'nin avantajı: kart sahibi bilgilerini güncellediğinde alıcılar da güncel veriyi görebilir.

### 12.2 Akış diyagramı (Mod B)

```
Kart sahibi (A)                    Alan (B)
      │                                │
      ├─ QR oluştur (cardId)          │
      │                                ├─ QR oku
      │                                ├─ GET /PublicBusinessCardShare
      │                                ├─ POST /SaveSavedCard
      │                                └─ Cüzdanda görünür
```

Detaylı akış: `docs/QR_CARD_WALLET_FLOW.md`

---

## Birim 13 — Premium abonelik (RevenueCat)

### 13.1 Neden backend'e ödeme gitmez?

Ödeme **App Store / Google Play** üzerinden yapılır. Backend doğrudan Apple/Google ile konuşmaz; arada **RevenueCat** vardır.

### 13.2 Akış

```
1. Kullanıcı uygulamada "Premium'a geç" der
2. RevenueCat SDK → App Store / Play Store ödeme ekranı
3. Ödeme başarılı → RevenueCat doğrular
4. RevenueCat → POST /RevenueCatWebhook (backend'e bildirim)
5. Backend → wallet_entitlements tablosunu günceller (Premium, 200 kart)
6. Flutter → GET /WalletQuota veya /PlanEntitlements ile güncel limiti okur
```

### 13.3 Neden sunucuda tutulur?

Premium durumu sunucuda tutulursa istemci tarafında limit bypass edilemez. Free kullanıcı 16. kartı eklemeye çalışırsa backend reddeder.

---

## Birim 14 — Production ortamı ve deploy

### 14.1 Ortam tablosu

| Bileşen | Adres / Platform |
|---------|-----------------|
| API (production) | `https://cardenceapi.app` |
| API (local) | `https://localhost:7241` |
| Swagger (local) | `https://localhost:7241/swagger` |
| Hosting | Railway (Docker container) |
| DNS / CDN | Cloudflare |
| Veritabanı | Railway PostgreSQL |

### 14.2 Railway monorepo ayarı

Repo kökü Flutter projesidir; API `backend/` altındadır. Railway'de:

| Ayar | Değer |
|------|-------|
| Root Directory | `backend` |
| Builder | Dockerfile |
| PostgreSQL | Ayrı servis (zorunlu) |

PostgreSQL olmadan API startup'ta crash eder.

### 14.3 Kritik environment variable'lar

| Variable | Açıklama |
|----------|----------|
| `ASPNETCORE_ENVIRONMENT` | `Production` |
| `ConnectionStrings__Default` | PostgreSQL bağlantı string'i |
| `Jwt__SigningKey` | JWT imza anahtarı (32+ karakter, gizli) |
| `Api__PublicBaseUrl` | `https://cardenceapi.app` |
| `Database__UseInMemory` | `false` (production'da) |

Detay: `backend/docs/deployment-cardenceapi.app.md`

---

## Birim 15 — Yerel geliştirme (hands-on)

### 15.1 Backend'i çalıştırma

```bash
# 1. PostgreSQL başlat
cd backend/database
cp .env.example .env
./scripts/start.sh

# 2. Migration uygula
./scripts/migrate.sh

# 3. API'yi çalıştır
cd ..
dotnet watch run --project Cardence.Api
```

Swagger: https://localhost:7241/swagger

### 15.2 Flutter'ı local API'ye bağlama

```bash
flutter run --dart-define=API_BASE_URL=https://localhost:7241
```

### 15.3 Cihaz → API erişim tablosu

| Ortam | API base URL |
|-------|--------------|
| iOS Simulator | `https://localhost:7241` |
| Android Emulator | `https://10.0.2.2:7241` |
| Fiziksel cihaz | Bilgisayarın LAN IP'si (ör. `https://192.168.1.x:7241`) |

### 15.4 PostgreSQL bağlantı bilgileri (local)

| Alan | Değer |
|------|-------|
| Host | `localhost:5432` |
| Database | `cardence` |
| User / Password | `postgres` / `dev` |

### 15.5 Faydalı komutlar

```bash
# Backend derle
cd backend && dotnet build

# Test çalıştır
cd backend && dotnet test

# Yeni migration oluştur
cd backend
dotnet ef migrations add MigrationAdi --project Cardence.Infrastructure --startup-project Cardence.Api

# Swagger'dan endpoint test et
# → https://localhost:7241/swagger
# → /Authentication ile giriş yap, token al
# → "Authorize" butonuna token yapıştır
# → Diğer endpoint'leri dene
```

---

## Birim 16 — Sözlük ve referanslar

### 16.1 Sözlük (glossary)

| Terim | Açıklama |
|-------|----------|
| **API** | Uygulamaların HTTP üzerinden konuştuğu arayüz |
| **Endpoint** | Belirli bir URL + HTTP metodu (ör. `GET /SavedCards`) |
| **JWT** | JSON Web Token — imzalı oturum kanıtı |
| **Bearer Token** | HTTP header'da taşınan JWT formatı |
| **DTO** | Data Transfer Object — API'de taşınan veri şekli |
| **Entity** | Domain'deki saf iş nesnesi (ör. `SavedCard`) |
| **Repository** | Veri erişim soyutlaması (interface + impl) |
| **ORM (EF Core)** | C# sınıflarını SQL tablolarına otomatik map eder |
| **Migration** | Veritabanı şema değişikliği dosyası |
| **Webhook** | Dış servisin backend'e olay bildirmesi (RevenueCat) |
| **Stateless** | Sunucunun oturum tablosu tutmaması |
| **Envelope** | `{ success, data, error, traceId }` standart yanıt formatı |
| **Clean Architecture** | Katmanlı mimari; iç katman dış katmana bağımlı değil |
| **Offline-first** | İnternet olmadan da çalışan, sunucu varsa senkronize eden strateji |
| **Monorepo** | Tek Git reposunda birden fazla proje (Flutter + .NET) |

### 16.2 Proje içi referans dokümanlar

| Dosya | İçerik |
|-------|--------|
| `backend/README.md` | Backend hızlı başlangıç |
| `backend/docs/dotnet-backend-api.md` | Tüm endpoint ve DTO spesifikasyonu |
| `backend/docs/database-design.md` | Veritabanı şeması ve ilişkiler |
| `backend/docs/backend-development.md` | Geliştirme rehberi ve faz planı |
| `backend/docs/deployment-cardenceapi.app.md` | Production deploy rehberi |
| `backend/database/README.md` | PostgreSQL kurulum |
| `docs/SOCIAL_LOGIN_SETUP.md` | Google/Apple/LinkedIn giriş |
| `docs/QR_CARD_WALLET_FLOW.md` | QR paylaşım akışı |
| `docs/ARCHITECTURE.md` | Flutter mimarisi |
| `.cursor/rules/dotnet-api.mdc` | Backend geliştirme kuralları |

### 16.3 Beş cümlede özet

1. Cardence backend'i **ASP.NET Core + PostgreSQL** ile yazılmış bir REST API'dir; production adresi `https://cardenceapi.app`.
2. Mobil uygulama **Dio** ile HTTP isteği atar; giriş sonrası her istekte **JWT Bearer token** gönderir.
3. Veriler **users, business_cards, saved_cards, event_groups** tablolarında tutulur; her kayıt bir kullanıcıya (`user_id`) bağlıdır.
4. Flutter **offline-first** çalışır: sunucu varsa senkronize eder, yoksa local cache kullanır.
5. Firebase Auth kullanılmaz; oturum, kota, premium ve çok cihaz senkronu tamamen bu backend üzerinden yönetilir.

---

*Bu doküman Cardence backend sisteminin eğitim amaçlı genel bakışını sunar. Endpoint detayları, DTO alanları ve iş kuralları için `backend/docs/dotnet-backend-api.md` tek kaynak dokümandır.*
