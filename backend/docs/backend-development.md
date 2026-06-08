# Cardence Backend Geliştirme Rehberi

Bu doküman, Cardence .NET API'sinin **sıfırdan geliştirilmesi** için gereken tüm adımları kapsar: ortam kurulumu, proje yapısı, Cursor ile AI destekli geliştirme akışı, faz planı ve Flutter entegrasyonu.

**İlgili dokümanlar:**

| Doküman | İçerik |
|---------|--------|
| **Bu dosya** (`backend-development.md`) | Nasıl geliştirilir — kurulum, Cursor, fazlar, prompt'lar |
| [`dotnet-backend-api.md`](./dotnet-backend-api.md) | Ne geliştirilir — endpoint'ler, DTO'lar, iş kuralları |
| [`database-design.md`](./database-design.md) | Veritabanı — tablolar, ilişkiler, auth, migration |

---

## İçindekiler

1. [Genel Bakış](#1-genel-bakış)
2. [Ön Gereksinimler](#2-ön-gereksinimler)
3. [Workspace Kurulumu](#3-workspace-kurulumu)
4. [.NET Solution İskeleti](#4-net-solution-iskeleti)
5. [Veritabanı (PostgreSQL)](#5-veritabanı-postgresql)
6. [Cursor Yapılandırması](#6-cursor-yapılandırması)
7. [Geliştirme Fazları](#7-geliştirme-fazları)
8. [Cursor Prompt Şablonları](#8-cursor-prompt-şablonları)
9. [Günlük Geliştirme Döngüsü](#9-günlük-geliştirme-döngüsü)
10. [Yapılandırma Dosyaları](#10-yapılandırma-dosyaları)
11. [Test ve Doğrulama](#11-test-ve-doğrulama)
12. [Flutter Entegrasyonu](#12-flutter-entegrasyonu)
13. [Sık Hatalar ve Çözümler](#13-sık-hatalar-ve-çözümler)
14. [Kontrol Listeleri](#14-kontrol-listeleri)

---

## 1. Genel Bakış

### 1.1 Ne inşa ediyoruz?

Cardence Flutter uygulaması bugün **offline-first** çalışır; veriler `SharedPreferences` üzerinde JSON olarak saklanır. .NET backend bu verilerin **bulut senkronizasyonu**, **QR ile kart çözümleme** ve **çok cihazlı kullanım** için HTTP API sağlar.

```
┌─────────────────┐     HTTPS/JWT      ┌──────────────────────────┐
│  Flutter App    │ ◄────────────────► │  Cardence .NET API         │
│  lib/features/  │                    │  backend/                  │
│  domain/        │                    │  ASP.NET Core 8+           │
│  repositories   │                    │  EF Core + PostgreSQL      │
└─────────────────┘                    └──────────────────────────┘
```

### 1.2 Backend modülleri

| Modül | Flutter karşılığı | Öncelik |
|-------|-------------------|---------|
| Auth | `AuthConstants`, `AuthProvider` | Faz 1 |
| BusinessCards | `OnboardingCardDraft`, `OnboardingRepository` | Faz 1 |
| Public Cards | `CardSharePayload` | Faz 1 |
| Wallet | `SavedCard`, `AddSavedCard` | Faz 2 |
| EventGroups | `EventGroup` | Faz 3 |
| Subscriptions | `WalletPlanTier` | Faz 4 |

**Backend'e gitmeyecek:** `ThemePreference` (cihaz-local kalır).

### 1.3 Mimari prensipler

- **Clean Architecture:** `Domain → Application → Infrastructure → Api`
- **Domain katmanı:** ASP.NET Core, EF Core import **yok**
- **Tek kaynak:** API sözleşmeleri [`dotnet-backend-api.md`](./dotnet-backend-api.md) ile uyumlu
- **Flutter uyumu:** DTO alan adları `lib/features/**/data/models/` JSON formatıyla birebir

---

## 2. Ön Gereksinimler

### 2.1 Yazılımlar

| Araç | Minimum sürüm | Kontrol |
|------|---------------|---------|
| .NET SDK | 8.0 | `dotnet --version` |
| Docker Desktop | — | `docker --version` |
| Cursor | Güncel | IDE |
| Git | — | `git --version` |

### 2.2 Opsiyonel

- **EF Core CLI:** `dotnet tool install --global dotnet-ef`
- **PostgreSQL client:** pgAdmin, DBeaver veya `psql`
- **HTTP test:** Postman, Bruno veya Swagger UI

### 2.3 Hesaplar (production için)

- Apple Developer (TestFlight/App Store)
- Google Cloud Console (Google Sign-In)
- App Store Connect / Google Play (Premium abonelik webhook'ları)

---

## 3. Workspace Kurulumu

### 3.1 Monorepo yapısı (önerilen)

Flutter ve backend aynı Cursor workspace'inde:

```
cardence/
├── lib/                              # Flutter uygulaması
├── .cursor/
│   └── rules/
│       ├── clean-architecture.mdc    # Flutter kuralları
│       └── dotnet-api.mdc            # Backend kuralları
└── backend/                          # .NET API
    ├── docs/
    │   ├── backend-development.md    # ← Bu dosya
    │   ├── dotnet-backend-api.md     # API referansı
    │   └── database-design.md        # Veritabanı tasarımı
    ├── Cardence.sln
    ├── Cardence.Api/
    ├── Cardence.Application/
    ├── Cardence.Domain/
    ├── Cardence.Infrastructure/
    └── Cardence.Tests/
```

### 3.2 Ayrı repo alternatifi

Backend ayrı repodaysa Cursor'da:

**File → Add Folder to Workspace** ile `cardence` (Flutter) ve `cardence-api` (backend) klasörlerini birleştir.

---

## 4. .NET Solution İskeleti

### 4.1 İlk kurulum komutları

Cursor terminalinde veya Agent'a çalıştır:

```bash
cd /Users/furkancaglar/Desktop/cardence
mkdir -p backend && cd backend

dotnet new sln -n Cardence

dotnet new webapi -n Cardence.Api -o Cardence.Api --use-controllers
dotnet new classlib -n Cardence.Domain -o Cardence.Domain
dotnet new classlib -n Cardence.Application -o Cardence.Application
dotnet new classlib -n Cardence.Infrastructure -o Cardence.Infrastructure
dotnet new xunit -n Cardence.Tests -o Cardence.Tests

dotnet sln add Cardence.Api Cardence.Domain Cardence.Application Cardence.Infrastructure Cardence.Tests
```

### 4.2 Proje referansları

```bash
cd backend

dotnet add Cardence.Application/Cardence.Application.csproj reference Cardence.Domain/Cardence.Domain.csproj
dotnet add Cardence.Infrastructure/Cardence.Infrastructure.csproj reference Cardence.Application/Cardence.Application.csproj
dotnet add Cardence.Infrastructure/Cardence.Infrastructure.csproj reference Cardence.Domain/Cardence.Domain.csproj
dotnet add Cardence.Api/Cardence.Api.csproj reference Cardence.Application/Cardence.Application.csproj
dotnet add Cardence.Api/Cardence.Api.csproj reference Cardence.Infrastructure/Cardence.Infrastructure.csproj
dotnet add Cardence.Tests/Cardence.Tests.csproj reference Cardence.Application/Cardence.Application.csproj
dotnet add Cardence.Tests/Cardence.Tests.csproj reference Cardence.Domain/Cardence.Domain.csproj
```

### 4.3 NuGet paketleri

**Cardence.Api:**
```bash
dotnet add Cardence.Api package Microsoft.AspNetCore.Authentication.JwtBearer
dotnet add Cardence.Api package Swashbuckle.AspNetCore
dotnet add Cardence.Api package Serilog.AspNetCore
```

**Cardence.Application:**
```bash
dotnet add Cardence.Application package FluentValidation
dotnet add Cardence.Application package FluentValidation.DependencyInjectionExtensions
```

**Cardence.Infrastructure:**
```bash
dotnet add Cardence.Infrastructure package Microsoft.EntityFrameworkCore
dotnet add Cardence.Infrastructure package Npgsql.EntityFrameworkCore.PostgreSQL
dotnet add Cardence.Infrastructure package Microsoft.EntityFrameworkCore.Design
```

### 4.4 Katman sorumlulukları

| Proje | İçerik |
|-------|--------|
| `Cardence.Domain` | Entity'ler, enum'lar, domain exception'ları |
| `Cardence.Application` | Use case'ler, DTO'lar, validator'lar, interface'ler |
| `Cardence.Infrastructure` | EF Core `DbContext`, repository impl, JWT, OAuth |
| `Cardence.Api` | Controller'lar, middleware, `Program.cs`, Swagger |
| `Cardence.Tests` | Unit + integration testler |

### 4.5 Klasör yapısı (hedef)

```
Cardence.Api/
├── Controllers/
│   ├── AuthController.cs
│   ├── CardsController.cs
│   ├── PublicCardsController.cs
│   ├── WalletController.cs
│   └── EventGroupsController.cs
├── Middleware/
│   └── ExceptionHandlingMiddleware.cs
└── Program.cs

Cardence.Application/
├── DTOs/
├── Validators/
├── Interfaces/
└── Services/

Cardence.Domain/
├── Entities/
├── Enums/
└── Exceptions/

Cardence.Infrastructure/
├── Persistence/
│   ├── CardenceDbContext.cs
│   ├── Configurations/
│   └── Migrations/
├── Repositories/
└── Auth/
```

---

## 5. Veritabanı (PostgreSQL)

### 5.1 Docker ile local DB

```bash
docker run -d \
  --name cardence-db \
  -e POSTGRES_USER=postgres \
  -e POSTGRES_PASSWORD=dev \
  -e POSTGRES_DB=cardence \
  -p 5432:5432 \
  postgres:16

# Kontrol
docker ps
```

### 5.2 Migration komutları

```bash
cd backend

# İlk migration
dotnet ef migrations add InitialCreate \
  --project Cardence.Infrastructure \
  --startup-project Cardence.Api

# Veritabanını güncelle
dotnet ef database update \
  --project Cardence.Infrastructure \
  --startup-project Cardence.Api
```

Detaylı tablo şeması: [`dotnet-backend-api.md` — Bölüm 11](./dotnet-backend-api.md#11-veritabanı-şeması).

---

## 6. Cursor Yapılandırması

### 6.1 Backend Cursor Rule

Projede `.cursor/rules/dotnet-api.mdc` dosyası tanımlıdır. Agent `backend/**` dosyalarında şu kuralları uygular:

- Clean Architecture katman ayrımı
- `backend/docs/dotnet-backend-api.md` tek API kaynağı
- Flutter DTO uyumu
- Secret'ların commit edilmemesi

Rule güncellemek için Cursor'a:

> `@.cursor/rules/dotnet-api.mdc` dosyasını `backend/docs/dotnet-backend-api.md` ile senkronize et.

### 6.2 Hangi mod ne zaman?

| Cursor modu | Kullanım |
|-------------|----------|
| **Plan** | Mimari kararlar: auth stratejisi, DB normalizasyonu, monorepo yapısı |
| **Agent** | Kod yazma, migration, controller, test, `dotnet build` |
| **Ask** | "Bu endpoint hangi Flutter use case?" gibi sorular |

### 6.3 @ referansları (context bağlama)

Her prompt'ta ilgili dosyaları `@` ile ekle:

```
@backend/docs/dotnet-backend-api.md
@backend/docs/backend-development.md
@lib/features/onboarding/data/models/onboarding_card_draft_model.dart
@lib/features/saved_cards/domain/usecases/add_saved_card.dart
@.cursor/rules/dotnet-api.mdc
```

| Referans | Ne zaman |
|----------|----------|
| `dotnet-backend-api.md` | Endpoint, DTO, iş kuralı |
| `onboarding_card_draft_model.dart` | BusinessCard JSON alanları |
| `saved_card_model.dart` | Wallet JSON alanları |
| `card_share_payload.dart` | QR/public endpoint |
| `add_saved_card.dart` | Cüzdan ekleme kuralları |
| `dotnet-api.mdc` | Backend kod stili |

### 6.4 İyi vs zayıf prompt

**İyi:**
```
@backend/docs/dotnet-backend-api.md
@lib/features/saved_cards/domain/usecases/add_saved_card.dart

POST /api/v1/wallet/cards endpoint'ini backend/ altında yaz.
- AddSavedCardResult → HTTP status eşlemesi dokümandaki gibi
- FluentValidation: cardId min 8 karakter
- dotnet build çalıştır, hata varsa düzelt
```

**Zayıf:**
```
Wallet API yap.
```

### 6.5 Agent'a terminal görevi verme

Agent şu komutları çalıştırabilir; prompt sonuna ekle:

```
Bitince sırayla çalıştır:
1. dotnet build backend/
2. dotnet test backend/
3. Hata varsa düzelt ve tekrar dene
```

---

## 7. Geliştirme Fazları

Her faz **ayrı branch** veya **ayrı PR** olarak ilerletilir. Faz bitince Swagger'dan manuel test yap.

### Faz 0 — İskelet

**Hedef:** Derlenen boş solution, Swagger, health check.

**Çıktılar:**
- [ ] Solution + proje referansları
- [ ] `Program.cs` DI kayıtları
- [ ] Swagger (`/swagger`)
- [ ] `GET /health`
- [ ] Standart API response zarfı (`success`, `data`, `error`, `traceId`)
- [ ] Global exception middleware

**Tahmini süre:** 0.5–1 gün

---

### Faz 1 — Auth + Business Cards + Public QR

**Hedef:** Kullanıcı girişi ve kendi kartları; QR çözümleme.

**Endpoint'ler:**
- `POST /api/v1/auth/google`
- `POST /api/v1/auth/apple`
- `GET /api/v1/auth/me`
- `GET/POST/PUT/DELETE /api/v1/cards`
- `GET /api/v1/cards/{cardId}/share`
- `GET /api/v1/public/cards/{cardId}`

**Çıktılar:**
- [ ] JWT Bearer middleware
- [ ] `User`, `BusinessCard` entity + migration
- [ ] `linkedEventGroupIds` request'te ignore
- [ ] `CardSharePayload` kısa anahtarlar (`id`, `n`, `e`…)

**Tahmini süre:** 3–5 gün

---

### Faz 2 — Wallet

**Hedef:** Kaydedilen kartlar ve kota.

**Endpoint'ler:**
- `GET /api/v1/wallet/cards`
- `POST /api/v1/wallet/cards`
- `PUT /api/v1/wallet/cards/{cardId}`
- `DELETE /api/v1/wallet/cards/{cardId}`
- `GET /api/v1/wallet/quota`

**İş kuralları:**
- Duplicate → `409 WALLET_DUPLICATE_CARD`
- Limit (Free 15 / Premium 200) → `403 WALLET_LIMIT_REACHED`
- `savedAt` → Unix **milliseconds**

**Tahmini süre:** 2–3 gün

---

### Faz 3 — Event Groups

**Hedef:** Etkinlik grupları ve saved card bağlantıları.

**Endpoint'ler:**
- `GET/POST/PUT/DELETE /api/v1/event-groups`
- `POST/DELETE /api/v1/event-groups/{id}/cards`

**İş kuralları:**
- Grup adı boş olamaz
- Case-insensitive duplicate ad yasak
- Grup silinince saved card'lardan unlink

**Tahmini süre:** 2 gün

---

### Faz 4 — Subscriptions

**Hedef:** Premium plan ve gerçek ödeme.

**Endpoint'ler:**
- `GET /api/v1/subscriptions/entitlement`
- `POST /api/v1/subscriptions/upgrade`
- Webhook'lar (App Store / Play Store)

**Tahmini süre:** 3–5 gün

---

### Faz 5 — Flutter Remote DataSource

**Hedef:** Flutter repository'leri HTTP'e bağla.

**Çıktılar:**
- [ ] `lib/core/network/api_client.dart`
- [ ] `onboarding_remote_datasource.dart`
- [ ] `saved_card_remote_datasource.dart`
- [ ] Auth interceptor + token refresh
- [ ] Offline cache stratejisi (opsiyonel)

**Tahmini süre:** 3–5 gün

---

## 8. Cursor Prompt Şablonları

Aşağıdaki prompt'ları sırayla Cursor **Agent** moduna yapıştır.

### 8.1 Faz 0 — Solution iskeleti

```
@backend/docs/dotnet-backend-api.md
@backend/docs/backend-development.md
@.cursor/rules/dotnet-api.mdc

Cardence .NET backend'ini backend/ klasöründe oluştur.

1. Bölüm 4'teki solution iskeleti ve proje referansları
2. NuGet paketleri (JWT, EF Core, PostgreSQL, FluentValidation, Swagger, Serilog)
3. Standart API response zarfı: { success, data, error, traceId }
4. Global exception handling middleware
5. Swagger + GET /health

Henüz business endpoint yazma.
Bitince: dotnet build backend/
```

### 8.2 Faz 1a — Domain + DB

```
@backend/docs/dotnet-backend-api.md (Bölüm 11)
@lib/features/onboarding/domain/entities/onboarding_card_draft.dart

Cardence.Domain ve Cardence.Infrastructure oluştur:
- User, BusinessCard entity'leri
- CardenceDbContext + EF configuration
- İlk migration (PostgreSQL)
- dotnet ef database update

Domain'de ASP.NET/EF import olmasın.
```

### 8.3 Faz 1b — Public card endpoint

```
@backend/docs/dotnet-backend-api.md (Bölüm 6.3, 7.3)
@lib/features/saved_cards/domain/entities/card_share_payload.dart

GET /api/v1/public/cards/{cardId} implement et.
- CardSharePayload kısa anahtarlar: id, n, e, p, c, t, w, l, s, o, h
- Boş alanlar JSON'a dahil edilmesin
- 404 → CARD_NOT_FOUND
- Swagger'a ekle
- Unit test: var olan / olmayan cardId
```

### 8.4 Faz 1c — Business Cards CRUD

```
@backend/docs/dotnet-backend-api.md (Bölüm 6.2, 7.1, 8.1)
@lib/features/onboarding/data/models/onboarding_card_draft_model.dart
@lib/features/onboarding/domain/usecases/save_onboarding_draft_card.dart

/api/v1/cards CRUD (JWT korumalı):
- JSON alan adları OnboardingCardDraftModel.toJson() ile birebir
- linkedEventGroupIds her zaman ignore / boş
- frontVisibleFields max 3, backVisibleFields max 3
- FluentValidation kuralları Bölüm 9'dan

Bitince dotnet test backend/
```

### 8.5 Faz 1d — Google/Apple Auth

```
@backend/docs/dotnet-backend-api.md (Bölüm 4, 6.1)
@lib/core/constants/auth_constants.dart

Auth implement et:
- POST /api/v1/auth/google (idToken doğrula → JWT)
- POST /api/v1/auth/apple
- GET /api/v1/auth/me
- POST /api/v1/auth/refresh

JwtBearer middleware. appsettings.Development.json şablonu ekle.
Secret'ları .gitignore'a ekle.
```

### 8.6 Faz 2 — Wallet

```
@backend/docs/dotnet-backend-api.md (Bölüm 6.4, 8.2)
@lib/features/saved_cards/domain/usecases/add_saved_card.dart
@lib/features/saved_cards/data/models/saved_card_model.dart

Wallet modülü:
- SavedCard entity + migration
- GET/POST/PUT/DELETE /api/v1/wallet/cards
- GET /api/v1/wallet/quota
- AddSavedCard kuralları: duplicate 409, limit 403, invalid 400
- savedAt Unix milliseconds

Integration test: limit aşımı senaryosu.
```

### 8.7 Faz 3 — Event Groups

```
@backend/docs/dotnet-backend-api.md (Bölüm 6.5, 8.3)
@lib/features/event_groups/data/models/event_group_model.dart

Event groups:
- saved_card_event_groups join tablosu
- CRUD + link/unlink endpoints
- Grup silme cascade
- Duplicate isim → 409 DUPLICATE_EVENT_GROUP_NAME
```

### 8.8 Faz 5 — Flutter entegrasyonu

```
@backend/docs/dotnet-backend-api.md (Bölüm 12)
@lib/features/saved_cards/domain/repositories/saved_card_repository.dart
@lib/features/onboarding/domain/repositories/onboarding_repository.dart

Flutter tarafında:
1. lib/core/network/api_client.dart (Dio)
2. auth_interceptor.dart (JWT refresh)
3. SavedCardRemoteDataSource
4. OnboardingRemoteDataSource
Domain repository interface'leri değişmesin.
DI: AppInit'te remote/local seçimi için flag veya flavor.
```

---

## 9. Günlük Geliştirme Döngüsü

```
1. backend/docs/dotnet-backend-api.md → ilgili endpoint bölümünü oku
2. Cursor Agent → faz prompt'unu @ referanslarla çalıştır
3. Terminal → dotnet watch run --project backend/Cardence.Api
4. Swagger → endpoint'i manuel test et
5. (Faz 5+) Flutter → remote datasource ile uçtan uca test
6. Git → faz bazlı commit
```

### Çalıştırma komutları

```bash
# API (hot reload)
cd backend && dotnet watch run --project Cardence.Api

# Build
dotnet build backend/

# Test
dotnet test backend/Cardence.Tests

# Swagger
# https://localhost:7xxx/swagger (port launchSettings.json'dan)
```

### Branch stratejisi

```
main
 └── feature/backend-phase-1-auth-cards
 └── feature/backend-phase-2-wallet
 └── feature/backend-phase-3-event-groups
 └── feature/flutter-remote-datasource
```

---

## 10. Yapılandırma Dosyaları

### 10.1 `appsettings.Development.json`

`backend/Cardence.Api/appsettings.Development.json`:

```json
{
  "ConnectionStrings": {
    "Default": "Host=localhost;Port=5432;Database=cardence;Username=postgres;Password=dev"
  },
  "Jwt": {
    "Issuer": "Cardence",
    "Audience": "Cardence.App",
    "SigningKey": "DEVELOPMENT-ONLY-MIN-32-CHARS-LONG!!",
    "AccessTokenMinutes": 60,
    "RefreshTokenDays": 30
  },
  "GoogleAuth": {
    "ClientId": "YOUR_GOOGLE_CLIENT_ID.apps.googleusercontent.com"
  },
  "AppleAuth": {
    "ClientId": "com.furkanages.cardence"
  },
  "Cors": {
    "AllowedOrigins": ["http://localhost:*"]
  },
  "Serilog": {
    "MinimumLevel": "Debug"
  }
}
```

### 10.2 `.gitignore` eklemeleri (backend/)

```
**/appsettings.Production.json
**/appsettings.*.local.json
.env
*.user
```

### 10.3 `launchSettings.json`

Development URL örneği:

```json
{
  "profiles": {
    "Cardence.Api": {
      "commandName": "Project",
      "launchBrowser": true,
      "launchUrl": "swagger",
      "applicationUrl": "https://localhost:7241;http://localhost:5241",
      "environmentVariables": {
        "ASPNETCORE_ENVIRONMENT": "Development"
      }
    }
  }
}
```

---

## 11. Test ve Doğrulama

### 11.1 Swagger ile manuel test

1. `dotnet watch run --project Cardence.Api`
2. `/swagger` aç
3. Auth → `POST /auth/google` (development'ta test token veya mock)
4. **Authorize** → Bearer token yapıştır
5. `GET /cards`, `POST /wallet/cards` dene

### 11.2 curl örnekleri

```bash
# Health
curl https://localhost:7241/health

# Public card (auth yok)
curl https://localhost:7241/api/v1/public/cards/{cardId}

# Authenticated
curl -H "Authorization: Bearer YOUR_JWT" \
  https://localhost:7241/api/v1/wallet/quota
```

### 11.3 Unit test kapsamı (minimum)

| Senaryo | Proje |
|---------|-------|
| AddSavedCard duplicate | `Cardence.Tests` |
| Wallet limit reached | `Cardence.Tests` |
| CardSharePayload serialize (boş alan omit) | `Cardence.Tests` |
| Onboarding validation rules | `Cardence.Tests` |
| EventGroup duplicate name | `Cardence.Tests` |

### 11.4 Flutter ↔ Backend uyum kontrolü

Her endpoint tamamlandığında:

```
@lib/features/saved_cards/data/models/saved_card_model.dart
@backend/docs/dotnet-backend-api.md

Backend SavedCardDto ile Flutter SavedCardModel JSON alanlarını karşılaştır.
Uyumsuzluk varsa listele ve düzelt.
```

---

## 12. Flutter Entegrasyonu

### 12.1 Değişmeyecek arayüzler

```dart
// lib/features/onboarding/domain/repositories/onboarding_repository.dart
abstract class OnboardingRepository {
  Future<bool> isOnboardingCompleted();
  Future<void> setOnboardingCompleted();
  Future<void> saveDraftCard(OnboardingCardDraft draft);
  Future<OnboardingCardDraft?> getDraftCard();
  Future<List<OnboardingCardDraft>> getDraftCards();
}

// lib/features/saved_cards/domain/repositories/saved_card_repository.dart
abstract class SavedCardRepository {
  Future<List<SavedCard>> getSavedCards();
  Future<void> saveCard(SavedCard card);
}
```

### 12.2 Eklenecek dosyalar

```
lib/core/network/
├── api_client.dart
├── api_config.dart
├── auth_interceptor.dart
└── api_exception.dart

lib/features/onboarding/data/datasources/
└── onboarding_remote_datasource.dart

lib/features/saved_cards/data/datasources/
└── saved_card_remote_datasource.dart
```

### 12.3 Geçiş stratejisi

| Aşama | Davranış |
|-------|----------|
| **Hybrid** | Auth + sync remote; theme local |
| **Offline cache** | Remote fetch → SharedPreferences cache |
| **Full online** | Auth zorunlu; local yalnızca cache |

### 12.4 QR akışı (backend sonrası)

**Şimdi:** QR içinde tam `CardSharePayload` JSON.

**Backend ile:**
1. QR → `https://cardence.app/c/{cardId}` veya `{"id":"..."}`
2. Client → `GET /api/v1/public/cards/{cardId}`
3. Response → `AddSavedCard` ile cüzdana ekle

---

## 13. Sık Hatalar ve Çözümler

| Hata | Neden | Çözüm |
|------|-------|-------|
| DTO alan adı Flutter'dan farklı | Model uyumsuzluğu | `@onboarding_card_draft_model.dart` referans ver |
| `savedAt` ISO string | Format farkı | Unix **ms** kullan (`DateTime.now().millisecondsSinceEpoch`) |
| CardSharePayload uzun anahtar | Yanlış DTO | `id`, `n`, `e` kısa anahtarları |
| Agent Flutter dosyası değiştiriyor | Scope karışıklığı | `backend/` altında çalış; `dotnet-api.mdc` rule aktif |
| EF migration hatası | DB kapalı | `docker ps` → PostgreSQL container çalışıyor mu |
| JWT 401 | Token süresi / yanlış issuer | `appsettings` Issuer/Audience kontrol |
| CORS hatası (Flutter web) | CORS tanımsız | `Program.cs` CORS policy ekle |
| `linkedEventGroupIds` dolu kayıt | İş kuralı atlandı | Save'de her zaman `[]` |
| TestFlight Invalid Signature | iOS build (ayrı konu) | Distribution certificate + Archive |

---

## 14. Kontrol Listeleri

### 14.1 Faz 1 tamamlandı mı?

- [ ] `dotnet build` hatasız
- [ ] `dotnet test` geçiyor
- [ ] Swagger'da tüm Faz 1 endpoint'leri görünüyor
- [ ] `GET /public/cards/{id}` auth gerektirmiyor
- [ ] `GET /cards` JWT gerektiriyor
- [ ] BusinessCard JSON = Flutter `OnboardingCardDraftModel`
- [ ] CardSharePayload = Flutter `CardSharePayload.toJson()`
- [ ] Migration PostgreSQL'de tabloları oluşturdu

### 14.2 Production öncesi

- [ ] `SigningKey` environment variable / Key Vault
- [ ] `appsettings.Production.json` git'te yok
- [ ] HTTPS zorunlu
- [ ] Rate limiting aktif
- [ ] Structured logging (Serilog → sink)
- [ ] Health check + DB connectivity
- [ ] CI: `dotnet build` + `dotnet test` pipeline

### 14.3 Flutter entegrasyon öncesi

- [ ] Base URL flavor/config (`dev` / `prod`)
- [ ] Token refresh akışı test edildi
- [ ] Offline fallback tanımlı
- [ ] `AddSavedCard` HTTP status → `AddSavedCardResult` mapping

---

## Hızlı Başlangıç (tek sayfa)

```bash
# 1. DB
docker run -d --name cardence-db -e POSTGRES_PASSWORD=dev -e POSTGRES_DB=cardence -p 5432:5432 postgres:16

# 2. Cursor Agent'a Faz 0 prompt'unu ver (Bölüm 8.1)

# 3. API çalıştır
cd backend && dotnet watch run --project Cardence.Api

# 4. Swagger aç → /swagger

# 5. Sırayla Faz 1–5 prompt'ları (Bölüm 8)
```

---

## Doküman seti özeti

| Dosya | Rol |
|-------|-----|
| `backend/docs/backend-development.md` | Nasıl geliştirilir — bu rehber |
| `backend/docs/dotnet-backend-api.md` | Ne geliştirilir — API spesifikasyonu |
| `backend/docs/database-design.md` | Veritabanı tasarımı |
| `.cursor/rules/dotnet-api.mdc` | Cursor Agent backend kuralları |

*Son güncelleme: Cardence Flutter codebase ve `lib/features/**/domain` katmanına göre hazırlanmıştır.*
