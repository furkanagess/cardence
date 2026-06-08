# Cardence .NET Backend

Cardence Flutter uygulaması için ASP.NET Core API (.NET 10).

## Dokümantasyon

- [Backend geliştirme rehberi](docs/backend-development.md)
- [API spesifikasyonu](docs/dotnet-backend-api.md)
- [Veritabanı tasarımı](docs/database-design.md)
- [Docker rehberi](docs/docker.md) — kurulum, kullanım, PostgreSQL container

## Gereksinimler

- [.NET 10 SDK](https://dotnet.microsoft.com/download) (veya .NET 8+)
- Docker (PostgreSQL için, Faz 1+)

## Yerel ayarlar (ilk kurulum)

```bash
cp Cardence.Api/appsettings.Development.json.example Cardence.Api/appsettings.Development.json
cp database/.env.example database/.env
```

## Hızlı başlangıç

```bash
# .NET SDK kurulumunu doğrula
dotnet --version
# "command not found" alırsan: export PATH="/usr/local/share/dotnet:$HOME/.dotnet:$PATH"
# Kalıcı çözüm: ~/.zshrc dosyasına aynı satır eklenmiş olmalı; sonra: source ~/.zshrc

# Derle
cd backend
dotnet restore
dotnet build

# Test
dotnet test

# Çalıştır
dotnet watch run --project Cardence.Api
```

Swagger (local): https://localhost:7241/swagger

Production: https://cardenceapi.app

Domain bağlantısı: [deploy/README.md](deploy/README.md)

Deploy rehberi: [docs/deployment-cardenceapi.app.md](docs/deployment-cardenceapi.app.md)

### Railway (monorepo)

Repo kökü Flutter; API `backend/` altında. Railway'de **Root Directory = `backend`** olmadan deploy Railpack hatası verir. Detay: [deployment rehberi](docs/deployment-cardenceapi.app.md#seçenek-a--railway-önerilen-hızlı).

Endpoint'ler PascalCase düz path kullanır (`/BusinessCards`, `/Authentication`). Swagger'da domain grupları altında listelenir.

## Proje yapısı

```
Cardence.Api            → HTTP, middleware, Swagger
Cardence.Application    → DTO, validators, use cases
Cardence.Domain         → Entities, domain exceptions
Cardence.Infrastructure → EF Core, repositories, auth
Cardence.Tests          → Unit tests
```

## Mevcut durum

- [x] Solution iskeleti
- [x] Standart API response zarfı
- [x] Global exception middleware
- [x] Swagger + health endpoint
- [x] Authentication servisleri
- [x] Business Cards CRUD
- [x] PostgreSQL + EF migration (`users`, `business_cards`)
- [ ] Wallet (Faz 2)
- [ ] Event Groups (Faz 3)

## PostgreSQL (mobil + backend)

Kalıcı veritabanı projesi: [`database/`](database/)

```bash
cd backend/database
cp .env.example .env
./scripts/start.sh      # Docker veya Homebrew PostgreSQL
./scripts/migrate.sh    # EF migration uygula

cd ..
dotnet watch run --project Cardence.Api
```

| Alan | Değer |
|------|-------|
| Host | `localhost:5432` |
| DB | `cardence` |
| User / Pass | `postgres` / `dev` |

Detay: [database/README.md](database/README.md)
