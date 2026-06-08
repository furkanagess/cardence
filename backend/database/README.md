# Cardence PostgreSQL

Mobil (Flutter) ve .NET backend'in paylaştığı kalıcı veritabanı.

## Mimari

```
Flutter App  ──HTTP──►  Cardence.Api  ──EF Core──►  PostgreSQL
                              │
                         JWT (users)
                         business_cards
```

| Tablo | Servisler |
|-------|-----------|
| `users` | `/Authentication`, `/LoginWithPhone`, `/LoginWithEmail` |
| `business_cards` | `/BusinessCards`, `/BusinessCard`, `/SaveBusinessCard`… |
| `saved_cards`, `wallet_entitlements` | *(planlanan — Wallet)* |
| `event_groups` | *(planlanan — EventGroups)* |

## Hızlı başlangıç

```bash
cd backend/database
cp .env.example .env

# Veritabanını başlat (Docker veya Homebrew)
chmod +x scripts/*.sh
./scripts/start.sh

# Tabloları oluştur (EF migration)
./scripts/migrate.sh

# API'yi çalıştır
cd ..
dotnet watch run --project Cardence.Api
```

Swagger: https://localhost:7241/swagger

## Bağlantı bilgileri

| Alan | Değer |
|------|-------|
| Host | `localhost` |
| Port | `5432` |
| Database | `cardence` |
| User | `postgres` |
| Password | `dev` |

Connection string (backend `appsettings.Development.json`):

```
Host=localhost;Port=5432;Database=cardence;Username=postgres;Password=dev
```

## Mobil cihazdan API erişimi

PostgreSQL'e mobil doğrudan bağlanmaz; Flutter yalnızca API'ye istek atar.

| Ortam | API base URL |
|-------|----------------|
| iOS Simulator | `https://localhost:7241` |
| Android Emulator | `https://10.0.2.2:7241` |
| Fiziksel cihaz | Bilgisayarın LAN IP'si (ör. `https://192.168.1.x:7241`) |

## Docker ile çalıştırma

Detaylı rehber: [docs/docker.md](../docs/docker.md)

```bash
docker compose up -d
docker compose logs -f postgres
docker compose exec postgres psql -U postgres -d cardence -c '\dt'
```

## Homebrew ile çalıştırma (Docker yoksa)

```bash
brew install postgresql@16
./scripts/start.sh
```

## Durdurma

```bash
./scripts/stop.sh
```

## Yeni migration

```bash
cd backend
dotnet ef migrations add <Name> \
  --project Cardence.Infrastructure \
  --startup-project Cardence.Api

dotnet ef database update \
  --project Cardence.Infrastructure \
  --startup-project Cardence.Api
```

Detaylı şema: [database-design.md](../docs/database-design.md)
